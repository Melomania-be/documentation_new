// scripts/generate-pdf.js
const fs = require('fs-extra');
const path = require('path');
const cheerio = require('cheerio');
const puppeteer = require('puppeteer');

// ==========================================
// CONFIGURATION
// ==========================================
const BUILD_DIR = path.resolve(__dirname, '../build');
const TARGET_DOCS_DIR = path.join(BUILD_DIR, 'Using the app');
const OUTPUT_FILE = path.resolve(__dirname, '../static/documentation.pdf');

const EXCLUDED_ITEMS = [
  'database',
  'intro',
  'workflows',
  'working on the app'
];

// ==========================================
// MAIN EXECUTION PIPELINE
// ==========================================
async function main() {
  console.log('🚀 Starting targeted PDF generation pipeline...');

  if (!fs.existsSync(TARGET_DOCS_DIR)) {
    console.error(`❌ Error: Target directory not found: "${TARGET_DOCS_DIR}"`);
    process.exit(1);
  }

  console.log('📂 Scanning folder hierarchy strictly inside "Using the app"...');
  const documentTree = buildDocTreeFromFilesystem(TARGET_DOCS_DIR);
  
  const flatDocsList = [];
  flattenTree(documentTree, flatDocsList);

  console.log(`📋 Found ${flatDocsList.length} documents matching targeted structural criteria.`);
  if (flatDocsList.length === 0) {
    console.error('❌ Error: No valid documentation pages found.');
    process.exit(1);
  }

  const tocHtml = generateTocHtml(documentTree);
  const bodyHtml = generateBodyHtml(flatDocsList);

  const finalHtmlDocument = `
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Documentation - Using the app</title>
      <style>
        @page {
          size: A4;
          margin: 20mm 15mm 20mm 15mm;
        }
        @media print {
          body {
            -webkit-print-color-adjust: exact;
            print-color-adjust: exact;
          }
          .page-break {
            page-break-before: always !important;
            break-before: page !important;
          }
          img {
            page-break-inside: avoid !important;
            break-inside: avoid !important;
          }
        }
        body {
          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
          line-height: 1.6;
          color: #333;
          padding: 0;
          margin: 0;
        }
        .page-break {
          page-break-before: always;
          break-before: page;
        }
        
        /* Table of Contents basique et robuste (évite les boucles infinies) */
        .toc-title { font-size: 28pt; margin-bottom: 30px; font-weight: bold; }
        .toc-list ul { list-style: none; padding-left: 0; }
        .toc-list li { margin: 12px 0; border-bottom: 1px dotted #ccc; display: flex; justify-content: space-between; }
        .toc-list span { background: white; padding-right: 5px; }
        .toc-list .level-1 { font-weight: bold; margin-top: 15px; font-size: 13pt; border-bottom: none; }
        .toc-list .level-2 { padding-left: 20px; font-size: 11pt; }
        .toc-list .level-3 { padding-left: 40px; font-size: 10pt; color: #555; }
        
        a { color: #0066cc; text-decoration: none; }
        pre, code { background: #f4f4f4; font-family: monospace; font-size: 10pt; }
        pre { padding: 15px; border-radius: 5px; overflow: hidden; white-space: pre-wrap; word-wrap: break-word; }
        
        /* Rendu forcé des images locales */
        img { 
          max-width: 100% !important; 
          height: auto !important; 
          display: block !important; 
          margin: 20px 0 !important;
          opacity: 1 !important;
          visibility: visible !important;
        }
        
        /* Suppression radicale des éléments d'interface web de Docusaurus */
        .hash-link, 
        svg, 
        .table-of-contents, 
        button, 
        .theme-doc-breadcrumbs, 
        .theme-edit-this-page, 
        .pagination-nav,
        .menu__link,
        .navbar,
        .footer { 
          display: none !important; 
        }
        
        h1, h2, h3, h4 { color: #111; font-weight: 700; margin-top: 25px; page-break-after: avoid; }
        h1 { font-size: 26pt; }
        h2 { font-size: 19pt; border-bottom: 1px solid #eee; padding-bottom: 5px; }
        h3 { font-size: 15pt; }
      </style>
    </head>
    <body>
      <div class="toc-page">
        <h1 class="toc-title">Table of Contents</h1>
        <div class="toc-list">${tocHtml}</div>
      </div>
      <div class="content-main">
        ${bodyHtml}
      </div>
    </body>
    </html>
  `;

  console.log('🎨 Compiling HTML print layout...');
  const tempHtmlPath = path.join(__dirname, '../build/print_preview.html');
  fs.writeFileSync(tempHtmlPath, finalHtmlDocument, 'utf8');

  const browser = await puppeteer.launch({ 
    headless: 'new',
    args: [
      '--allow-file-access-from-files', 
      '--disable-web-security',
      '--enable-local-file-accesses'
    ]
  });
  const page = await browser.newPage();
  
  console.log('⏳ Loading document into Chromium engine...');
  // On attend que le CPU soit au repos complet (toutes les images chargées du disque)
  await page.goto(`file://${tempHtmlPath}`, { waitUntil: 'networkidle0' });
  
  // Petit délai de sécurité pour laisser les images s'afficher à l'écran
  await new Promise(resolve => setTimeout(resolve, 2000));

  console.log('📸 Generating absolute PDF pages via Chromium Native Print...');
  await fs.ensureDir(path.dirname(OUTPUT_FILE));
  
  await page.pdf({
    path: OUTPUT_FILE,
    format: 'A4',
    printBackground: true,
    displayHeaderFooter: true,
    footerTemplate: `
      <div style="font-family: sans-serif; font-size: 8pt; width: 100%; text-align: right; padding-right: 15mm; color: #777;">
        <span class="pageNumber"></span> / <span class="totalPages"></span>
      </div>`,
    headerTemplate: '<div></div>', // Vide
    margin: {
      top: '20mm',
      bottom: '20mm',
      left: '15mm',
      right: '15mm'
    }
  });

  await browser.close();
  fs.unlinkSync(tempHtmlPath);
  console.log(`✨ Success! Complete PDF generated cleanly at: ${OUTPUT_FILE}`);
}

// ==========================================
// DIRECTORY SCANNING HELPER FUNCTIONS
// ==========================================

function buildDocTreeFromFilesystem(dirPath) {
  const items = fs.readdirSync(dirPath);
  const nodes = [];

  items.sort((a, b) => a.localeCompare(b, undefined, { numeric: true, sensitivity: 'base' }));

  for (const item of items) {
    const fullPath = path.join(dirPath, item);
    const isDir = fs.statSync(fullPath).isDirectory();

    if (EXCLUDED_ITEMS.some(exclude => item.toLowerCase().includes(exclude.toLowerCase()))) {
      continue;
    }

    if (isDir) {
      const children = buildDocTreeFromFilesystem(fullPath);
      const indexFile = path.join(fullPath, 'index.html');
      
      let title = item;
      let filePath = fs.existsSync(indexFile) ? indexFile : null;

      if (filePath) {
        title = extractTitleFromHtml(filePath) || title;
      }

      if (filePath || children.length > 0) {
        nodes.push({ title, filePath, children });
      }
    } else if (item.endsWith('.html') && item !== 'index.html' && item !== '404.html') {
      const title = extractTitleFromHtml(fullPath) || path.basename(item, '.html');
      nodes.push({ title, filePath: fullPath, children: [] });
    }
  }

  return nodes;
}

function extractTitleFromHtml(filePath) {
  try {
    const html = fs.readFileSync(filePath, 'utf8');
    const $ = cheerio.load(html);
    const h1Text = $('h1').first().text().trim();
    if (h1Text) return h1Text;
    const titleText = $('title').text().trim();
    return titleText.split('|')[0].trim();
  } catch (e) {
    return null;
  }
}

function flattenTree(treeNodes, flatList) {
  for (const node of treeNodes) {
    if (node.filePath) {
      flatList.push(node);
    }
    if (node.children.length) {
      flattenTree(node.children, flatList);
    }
  }
}

function generateTocHtml(treeNodes, level = 1) {
  let html = '<ul>';
  for (const node of treeNodes) {
    const anchorId = node.filePath ? `doc-${path.relative(BUILD_DIR, node.filePath).replace(/[\/\.\s]/g, '-').toLowerCase()}` : '';
    html += `<li class="level-${level}">`;
    if (anchorId) {
      html += `<a href="#${anchorId}"><span>${node.title}</span></a>`;
    } else {
      html += `<span>${node.title}</span>`;
    }
    if (node.children.length) {
      html += generateTocHtml(node.children, level + 1);
    }
    html += `</li>`;
  }
  html += '</ul>';
  return html;
}

function generateBodyHtml(flatList) {
  let html = '';
  for (const doc of flatList) {
    if (!fs.existsSync(doc.filePath)) continue;

    const fileContent = fs.readFileSync(doc.filePath, 'utf8');
    const $ = cheerio.load(fileContent);
    
    const mainContent = $('article, .theme-doc-markdown').first();
    if (!mainContent.length) continue;

    // Convertir les chemins d'images en absolus pour le disque local
    mainContent.find('img').each((_, img) => {
      const src = $(img).attr('src');
      if (src && src.startsWith('/')) {
        const absoluteImgPath = path.join(BUILD_DIR, src);
        $(img).attr('src', absoluteImgPath);
        // Supprimer les attributs de chargement asynchrone qui bloquent le rendu
        $(img).removeAttr('loading');
        $(img).removeAttr('decoding');
      }
    });

    mainContent.find('.theme-doc-breadcrumbs, .theme-edit-this-page, .pagination-nav, .hash-link, svg').remove();
    mainContent.find('p:contains("On this page")').remove();

    const anchorId = `doc-${path.relative(BUILD_DIR, doc.filePath).replace(/[\/\.\s]/g, '-').toLowerCase()}`;
    
    // Ajout d'un saut de page propre pour chaque nouveau document
    html += `<section id="${anchorId}" class="page-break">`;
    html += mainContent.html();
    html += `</section>`;
  }
  return html;
}

main().catch(err => console.error('❌ Pipeline failed:', err));