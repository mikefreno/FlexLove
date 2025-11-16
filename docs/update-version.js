const fs = require('fs');
const path = require('path');

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

// Update index.html with current version
function updateIndexVersion() {
  const version = getVersion();
  const indexPath = path.join(__dirname, 'index.html');
  let content = fs.readFileSync(indexPath, 'utf8');
  
  // Update version in multiple places
  content = content.replace(
    /FlexLöve v[\d.]+/g,
    `FlexLöve v${version}`
  );
  
  fs.writeFileSync(indexPath, content, 'utf8');
  console.log(`✓ Updated index.html to version ${version}`);
}

const version = getVersion();
console.log(`Current version: ${version}`);
updateIndexVersion();
