import fs from 'fs';
import path from 'path';

function stripComments(content, isCss) {
    if (isCss) {
        return content.replace(/\/\*[\s\S]*?\*\//g, '');
    }

    // Убираем многострочные комментарии /* ... */
    let newContent = content.replace(/\/\*[\s\S]*?\*\//g, '');

    // Убираем однострочные комментарии // ... , игнорируя те, что внутри строк
    newContent = newContent.split('\n').map(line => {
        let commentIndex = -1;
        let inString = null;
        for (let i = 0; i < line.length; i++) {
            const c = line[i];
            const next = line[i + 1];
            if ((c === '"' || c === "'" || c === '`') && line[i - 1] !== '\\') {
                if (!inString) inString = c;
                else if (inString === c) inString = null;
            } else if (!inString && c === '/' && next === '/') {
                commentIndex = i;
                break;
            }
        }
        if (commentIndex !== -1) {
            return line.substring(0, commentIndex);
        }
        return line;
    }).join('\n');

    // Убираем любые упоминания vibecoding (на всякий случай)
    newContent = newContent.replace(/vibecoding/gi, '');

    // Очищаем пустые скобки, которые могли остаться после удаления комментариев в JSX вида { /* ... */ }
    newContent = newContent.replace(/\{\s*\}/g, '');

    return newContent;
}

function processFiles(dir) {
    const files = fs.readdirSync(dir);
    for (const file of files) {
        const fullPath = path.join(dir, file);
        const stat = fs.statSync(fullPath);
        if (stat.isDirectory()) {
            processFiles(fullPath);
        } else if (/\.(js|jsx|css)$/.test(fullPath)) {
            const original = fs.readFileSync(fullPath, 'utf8');
            const stripped = stripComments(original, fullPath.endsWith('.css'));
            if (original !== stripped) {
                fs.writeFileSync(fullPath, stripped, 'utf8');
                console.log('Очищен файл:', fullPath);
            }
        }
    }
}

const srcDir = 'c:/Users/User/Desktop/school project/src';
console.log('Начинаю очистку комментариев в', srcDir, '...');
processFiles(srcDir);
console.log('Готово! Все комментарии и водяные знаки успешно удалены.');
