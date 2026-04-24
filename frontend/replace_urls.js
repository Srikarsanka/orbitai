const fs = require('fs');
const path = require('path');

const targetStr = 'https://orbitbackend-0i66.onrender.com';
const replacementStr = 'https://orbitbackend-0i66.onrender.com';

function scanAndReplace(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        if (file === 'node_modules' || file === '.git' || file === 'dist' || file === '.angular') continue;
        
        const filePath = path.join(dir, file);
        const stat = fs.statSync(filePath);
        if (stat.isDirectory()) {
            scanAndReplace(filePath);
        } else if (stat.isFile()) {
            if (filePath.endsWith('.ts') || filePath.endsWith('.html') || filePath.endsWith('.js') || filePath.endsWith('.css') || filePath.endsWith('.json')) {
                const content = fs.readFileSync(filePath, 'utf8');
                if (content.includes(targetStr)) {
                    const newContent = content.split(targetStr).join(replacementStr);
                    fs.writeFileSync(filePath, newContent, 'utf8');
                    console.log('Updated: ' + filePath);
                }
            }
        }
    }
}

scanAndReplace('c:\\ORBIT\\frontend');
