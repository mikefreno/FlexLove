const fs = require('fs');
const path = require('path');
const MarkdownIt = require('markdown-it');
const anchor = require('markdown-it-anchor');
const hljs = require('highlight.js');
const filter = require('./doc-filter');

// Extract version from FlexLove.lua
function getVersion() {
  try {
    const flexlovePath = path.join(__dirname, '..', 'FlexLove.lua');
    const content = fs.readFileSync(flexlovePath, 'utf8');
    const match = content.match(/flexlove\._VERSION\s*=\s*["']([^"']+)["']/);
    return match ? match[1] : 'unknown';
  } catch (e) {
    return 'unknown';
  }
}

const VERSION = getVersion();
console.log(`Building docs for FlexLöve v${VERSION}`);

const md = new MarkdownIt({
  html: true,
  linkify: true,
  typographer: true,
  highlight: function (str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(str, { language: lang }).value;
      } catch (__) {}
    }
    return '';
  }
}).use(anchor, {
  permalink: anchor.permalink.headerLink()
});

// Read the markdown file
let markdownContent = fs.readFileSync(path.join(__dirname, 'doc.md'), 'utf8');

// Filter content based on doc-filter.js configuration
function filterMarkdown(content) {
  const lines = content.split('\n');
  const filtered = [];
  let currentClass = null;
  let skipUntilNextClass = false;
  let classContent = [];
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];
    const h1Match = line.match(/^# (.+)$/);
    
    if (h1Match) {
      // New class found - decide if we should keep previous class
      if (currentClass && !skipUntilNextClass) {
        filtered.push(...classContent);
      }
      
      currentClass = h1Match[1];
      classContent = [line];
      
      // Check if this class should be included
      if (filter.mode === 'whitelist') {
        skipUntilNextClass = !filter.include.includes(currentClass);
      } else {
        skipUntilNextClass = filter.exclude.includes(currentClass);
      }
    } else {
      classContent.push(line);
    }
  }
  
  // Don't forget the last class
  if (currentClass && !skipUntilNextClass) {
    filtered.push(...classContent);
  }
  
  return filtered.join('\n');
}

markdownContent = filterMarkdown(markdownContent);

// Sort properties: public first, then internal (prefixed with _)
function sortAndInjectWarning(content) {
  const lines = content.split('\n');
  const result = [];
  let i = 0;
  
  while (i < lines.length) {
    const line = lines[i];
    
    // Check if this is a class heading (h1)
    if (line.match(/^# .+$/)) {
      // Found a class, collect all its properties/methods
      result.push(line);
      i++;
      
      const properties = [];
      let currentProperty = null;
      
      // Collect all properties until next class or end of file
      while (i < lines.length && !lines[i].match(/^# .+$/)) {
        const propLine = lines[i];
        const h2Match = propLine.match(/^## (.+)$/);
        
        if (h2Match) {
          // Save previous property if exists
          if (currentProperty) {
            properties.push(currentProperty);
          }
          // Start new property
          currentProperty = {
            name: h2Match[1],
            lines: [propLine],
            isInternal: h2Match[1].startsWith('_')
          };
        } else if (currentProperty) {
          // Add line to current property
          currentProperty.lines.push(propLine);
        } else {
          // Line before any property (e.g., class description)
          result.push(propLine);
        }
        i++;
      }
      
      // Save last property
      if (currentProperty) {
        properties.push(currentProperty);
      }
      
      // Sort: public first, then internal
      const publicProps = properties.filter(p => !p.isInternal);
      const internalProps = properties.filter(p => p.isInternal);
      
      // Add public properties
      publicProps.forEach(prop => {
        result.push(...prop.lines);
      });
      
      // Add warning and internal properties if any exist
      if (internalProps.length > 0) {
        result.push('');
        result.push('---');
        result.push('');
        result.push('## ⚠️ Internal Properties');
        result.push('');
        result.push('> **Warning:** The following properties are internal implementation details and should not be accessed directly. They are prefixed with `_` to indicate they are private. Accessing these properties may break in future versions without notice.');
        result.push('');
        result.push('---');
        result.push('');
        
        internalProps.forEach(prop => {
          result.push(...prop.lines);
        });
      }
    } else {
      result.push(line);
      i++;
    }
  }
  
  return result.join('\n');
}

markdownContent = sortAndInjectWarning(markdownContent);

// Parse markdown structure to build navigation
const lines = markdownContent.split('\n');
const navigation = [];
let currentClass = null;

lines.forEach(line => {
  const h1Match = line.match(/^# (.+)$/);
  const h2Match = line.match(/^## (.+)$/);
  
  if (h1Match) {
    currentClass = {
      name: h1Match[1],
      id: h1Match[1].toLowerCase().replace(/[^a-z0-9]+/g, '-'),
      members: []
    };
    navigation.push(currentClass);
  } else if (h2Match && currentClass) {
    currentClass.members.push({
      name: h2Match[1],
      id: h2Match[1].toLowerCase().replace(/[^a-z0-9]+/g, '-')
    });
  }
});

// Scan for available documentation versions
function getAvailableVersions() {
  const versionsDir = path.join(__dirname, 'versions');
  const versions = [];
  
  try {
    if (fs.existsSync(versionsDir)) {
      const entries = fs.readdirSync(versionsDir, { withFileTypes: true });
      for (const entry of entries) {
        if (entry.isDirectory() && entry.name.startsWith('v')) {
          const apiPath = path.join(versionsDir, entry.name, 'api.html');
          if (fs.existsSync(apiPath)) {
            versions.push(entry.name);
          }
        }
      }
    }
  } catch (e) {
    console.warn('Warning: Could not scan versions directory:', e.message);
  }
  
  // Sort versions (newest first)
  versions.sort((a, b) => {
    const parseVersion = (v) => {
      const parts = v.substring(1).split('.').map(Number);
      return parts[0] * 10000 + parts[1] * 100 + parts[2];
    };
    return parseVersion(b) - parseVersion(a);
  });
  
  return versions;
}

const availableVersions = getAvailableVersions();
console.log(`Found ${availableVersions.length} archived version(s):`, availableVersions.join(', '));

// Convert markdown to HTML
const htmlContent = md.render(markdownContent);

// Create HTML template
const template = `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FlexLöve v${VERSION} - API Reference</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans', Helvetica, Arial, sans-serif;
            background-color: #0d1117;
            color: #c9d1d9;
            line-height: 1.6;
        }
        
        .container {
            display: flex;
            min-height: 100vh;
        }
        
        .sidebar {
            width: 280px;
            background-color: #161b22;
            border-right: 1px solid #30363d;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            padding: 20px;
        }
        
        .sidebar-header {
            padding-bottom: 15px;
            border-bottom: 1px solid #30363d;
            margin-bottom: 15px;
        }
        
        .sidebar-header h2 {
            color: #58a6ff;
            font-size: 1.2rem;
        }
        
        .sidebar-header a {
            color: #8b949e;
            text-decoration: none;
            font-size: 0.9rem;
            display: block;
            margin-top: 5px;
        }
        
        .sidebar-header a:hover {
            color: #58a6ff;
        }
        
        #search {
            width: 100%;
            padding: 8px 12px;
            background-color: #0d1117;
            border: 1px solid #30363d;
            border-radius: 6px;
            color: #c9d1d9;
            font-size: 14px;
            margin-bottom: 15px;
        }
        
        #search:focus {
            outline: none;
            border-color: #58a6ff;
        }
        
        .nav-section {
            margin-bottom: 15px;
        }
        
        .nav-class {
            color: #c9d1d9;
            font-weight: 600;
            padding: 8px 12px;
            cursor: pointer;
            border-radius: 6px;
            transition: background-color 0.2s;
            display: block;
            text-decoration: none;
        }
        
        .nav-class:hover {
            background-color: #21262d;
        }
        
        .nav-members {
            display: none;
            padding-left: 20px;
            margin-top: 5px;
        }
        
        .nav-members.active {
            display: block;
        }
        
        .nav-member {
            color: #8b949e;
            padding: 4px 12px;
            font-size: 0.9rem;
            cursor: pointer;
            border-radius: 6px;
            transition: background-color 0.2s;
            display: block;
            text-decoration: none;
        }
        
        .nav-member:hover {
            background-color: #21262d;
            color: #c9d1d9;
        }
        
        .content {
            margin-left: 280px;
            flex: 1;
            padding: 40px 60px;
            max-width: 1200px;
        }
        
        .content h1 {
            color: #58a6ff;
            font-size: 2rem;
            margin: 2rem 0 1rem 0;
            padding-bottom: 0.5rem;
            border-bottom: 1px solid #30363d;
        }
        
        .content h1:first-child {
            margin-top: 0;
        }
        
        .content h2 {
            color: #79c0ff;
            font-size: 1.5rem;
            margin: 1.5rem 0 0.8rem 0;
            font-family: 'Courier New', monospace;
        }
        
        .content h3 {
            color: #c9d1d9;
            font-size: 1.2rem;
            margin: 1.2rem 0 0.6rem 0;
        }
        
        .content p {
            margin: 0.8rem 0;
            color: #c9d1d9;
        }
        
        .content code {
            background-color: #161b22;
            padding: 0.2em 0.4em;
            border-radius: 3px;
            font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
            font-size: 0.9em;
        }
        
        .content pre {
            background-color: #161b22;
            padding: 16px;
            border-radius: 6px;
            overflow-x: auto;
            margin: 1rem 0;
            border: 1px solid #30363d;
        }
        
        .content pre code {
            background-color: transparent;
            padding: 0;
        }
        
        .content a {
            color: #58a6ff;
            text-decoration: none;
        }
        
        .content a:hover {
            text-decoration: underline;
        }
        
        .content ul, .content ol {
            margin: 0.8rem 0;
            padding-left: 2rem;
        }
        
        .content li {
            margin: 0.4rem 0;
        }
        
        .content table {
            border-collapse: collapse;
            width: 100%;
            margin: 1rem 0;
        }
        
        .content th, .content td {
            border: 1px solid #30363d;
            padding: 8px 12px;
            text-align: left;
        }
        
        .content th {
            background-color: #161b22;
            font-weight: 600;
        }
        
        .content blockquote {
            background-color: #1c2128;
            border-left: 4px solid #f85149;
            padding: 12px 16px;
            margin: 1rem 0;
            border-radius: 6px;
        }
        
        .content blockquote p {
            margin: 0.4rem 0;
        }
        
        .content blockquote strong {
            color: #f85149;
        }
        
        .content hr {
            border: none;
            border-top: 1px solid #30363d;
            margin: 2rem 0;
        }
        
        .version-selector {
            margin-top: 10px;
            position: relative;
        }
        
        .version-selector select {
            width: 100%;
            padding: 8px 12px;
            background-color: #0d1117;
            border: 1px solid #30363d;
            border-radius: 6px;
            color: #c9d1d9;
            font-size: 14px;
            cursor: pointer;
            appearance: none;
            background-image: url('data:image/svg+xml;utf8,<svg fill="%238b949e" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16"><path d="M4.427 7.427l3.396 3.396a.25.25 0 00.354 0l3.396-3.396A.25.25 0 0011.396 7H4.604a.25.25 0 00-.177.427z"/></svg>');
            background-repeat: no-repeat;
            background-position: right 8px center;
            background-size: 12px;
            padding-right: 32px;
        }
        
        .version-selector select:hover {
            background-color: #161b22;
            border-color: #58a6ff;
        }
        
        .version-selector select:focus {
            outline: none;
            border-color: #58a6ff;
        }
        
        .version-badge {
            display: inline-block;
            background-color: #238636;
            color: #fff;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 10px;
            margin-left: 6px;
            font-weight: 600;
        }
        
        .back-to-top {
            position: fixed;
            bottom: 30px;
            right: 30px;
            background-color: #21262d;
            border: 1px solid #30363d;
            border-radius: 6px;
            padding: 10px 15px;
            color: #c9d1d9;
            text-decoration: none;
            opacity: 0;
            transition: opacity 0.3s;
        }
        
        .back-to-top.visible {
            opacity: 1;
        }
        
        .back-to-top:hover {
            background-color: #30363d;
        }
        
        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s;
                z-index: 1000;
            }
            
            .sidebar.mobile-open {
                transform: translateX(0);
            }
            
            .content {
                margin-left: 0;
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <nav class="sidebar">
            <div class="sidebar-header">
                <h2>FlexLöve <span style="font-size: 0.6em; color: #8b949e;">v${VERSION}</span></h2>
                <a href="index.html">← Back to Home</a>
                ${availableVersions.length > 0 ? `
                <div class="version-selector">
                    <select id="version-dropdown" onchange="window.versionNavigate(this.value)">
                        <option value="">📚 Switch Version</option>
                        <option value="current">v${VERSION} (Latest)</option>
                        ${availableVersions.map(v => `<option value="${v}">` + v + '</option>').join('\n                        ')}
                    </select>
                </div>
                ` : ''}
            </div>
            
            <input type="text" id="search" placeholder="Search API...">
            
            <div id="nav-content">
${navigation.map(cls => `
                <div class="nav-section" data-class="${cls.name.toLowerCase()}">
                    <a href="#${cls.id}" class="nav-class">${cls.name}</a>
                    <div class="nav-members">
${cls.members.map(member => `                        <a href="#${member.id}" class="nav-member">${member.name}</a>`).join('\n')}
                    </div>
                </div>
`).join('')}
            </div>
        </nav>
        
        <main class="content">
${htmlContent}
        </main>
    </div>
    
    <a href="#" class="back-to-top" id="backToTop">↑ Top</a>
    
    <script>
        // Search functionality
        const searchInput = document.getElementById('search');
        const navSections = document.querySelectorAll('.nav-section');
        
        searchInput.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase();
            
            navSections.forEach(section => {
                const className = section.querySelector('.nav-class').textContent.toLowerCase();
                const members = section.querySelectorAll('.nav-member');
                let hasMatch = className.includes(query);
                
                members.forEach(member => {
                    const memberName = member.textContent.toLowerCase();
                    if (memberName.includes(query)) {
                        member.style.display = 'block';
                        hasMatch = true;
                    } else {
                        member.style.display = 'none';
                    }
                });
                
                section.style.display = hasMatch ? 'block' : 'none';
                if (hasMatch && query) {
                    section.querySelector('.nav-members').classList.add('active');
                }
            });
        });
        
        // Expand/collapse navigation
        document.querySelectorAll('.nav-class').forEach(navClass => {
            navClass.addEventListener('click', (e) => {
                const members = navClass.nextElementSibling;
                members.classList.toggle('active');
            });
        });
        
        // Back to top button
        const backToTop = document.getElementById('backToTop');
        
        window.addEventListener('scroll', () => {
            if (window.scrollY > 300) {
                backToTop.classList.add('visible');
            } else {
                backToTop.classList.remove('visible');
            }
        });
        
        backToTop.addEventListener('click', (e) => {
            e.preventDefault();
            window.scrollTo({ top: 0, behavior: 'smooth' });
        });
        
        // Auto-expand current section
        const currentHash = window.location.hash;
        if (currentHash) {
            const section = document.querySelector(\`[href="\${currentHash}"]\`)?.closest('.nav-section');
            if (section) {
                section.querySelector('.nav-members').classList.add('active');
            }
        }
        
        // Version navigation
        window.versionNavigate = function(value) {
            if (!value) return;
            
            if (value === 'current') {
                // Navigate to current/latest version (root api.html)
                const currentPath = window.location.pathname;
                if (currentPath.includes('/versions/')) {
                    // We're in a versioned doc, go back to root
                    window.location.href = '../../api.html';
                }
                // Already on current, do nothing
            } else {
                // Navigate to specific version
                const currentPath = window.location.pathname;
                if (currentPath.includes('/versions/')) {
                    // We're in a versioned doc, navigate to sibling version
                    window.location.href = \`../\${value}/api.html\`;
                } else {
                    // We're in root, navigate to versions subdirectory
                    window.location.href = \`versions/\${value}/api.html\`;
                }
            }
        };
    </script>
</body>
</html>`;

// Write the HTML file
fs.writeFileSync(path.join(__dirname, 'api.html'), template, 'utf8');
console.log('✓ Generated api.html');
