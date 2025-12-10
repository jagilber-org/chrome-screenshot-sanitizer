// Azure Portal Iframe Sanitization Script
// Paste this in Chrome DevTools Console after switching to the iframe context

const replacements = [
  // Subscription name - try multiple patterns
  {regex: /ME-MngEnvMCAP706013-jagilber-1/gi, replacement: "contoso-subscription-001"},
  {regex: /MngEnvMCAP706013-jagilber-1/gi, replacement: "contoso-subscription-001"},
  // Email and tenant
  {regex: /admin@MngEnvMCAP706013\.onmicrosoft\.com/gi, replacement: "admin@contoso.com"},
  {regex: /ME-MngEnvMCAP706013\.onmicrosoft\.com/gi, replacement: "contoso.onmicrosoft.com"},
  {regex: /MngEnvMCAP706013\.onmicrosoft\.com/gi, replacement: "contoso.onmicrosoft.com"},
  {regex: /ME-MngEnvMCAP706013/gi, replacement: "contosotenant"},
  {regex: /MngEnvMCAP706013/gi, replacement: "contosotenant"},
  // GUIDs - with and without dashes
  // Full GUIDs
  {regex: /d692f14b-8df6-4f72-ab7d-b4b2981a6b58/gi, replacement: "bc311a87-c50e-4def-8d86-97f45e508b58"},
  {regex: /d692f14b8df64f72ab7db4b2981a6b58/gi, replacement: "bc311a87c50e4def8d8697f45e508b58"},
  {regex: /1310dfb0-a887-4ca0-8b9f-95690d4e9f8c/gi, replacement: "2aa10626-1ed0-401b-be45-b7df7a3fca10"},
  {regex: /1310dfb0a8874ca08b9f95690d4e9f8c/gi, replacement: "2aa106261ed0401bbe45b7df7a3fca10"},
  // Partial GUID at Monaco 50-char span boundary (drop last 12 chars to avoid span split)
  {regex: /d692f14b-8df6-4f72-ab7d-b4b2981a6b/gi, replacement: "bc311a87-c50e-4def-8d86-97f45e508b"},
  {regex: /(?<=bc311a87-c50e-4def-8d86-97f45e508b)58/gi, replacement: "58"}, // Add back the 58
  // Resources (specific names before generic)
  {regex: /sflogsorsuvwbkd2h5a2/gi, replacement: "sflogsservicefabriccluster"},
  {regex: /wadorsuvwbkd2h5a3/gi, replacement: "wadservicefabriccluster"},
  {regex: /sfjagilber-centralus/gi, replacement: "servicefabriccluster-kv"},
  {regex: /sfjagilber1nt3so/gi, replacement: "servicefabriccluster"},
  // Certificate thumbprints
  {regex: /CF5FA1BB54C5356FA853CAE416D7B950FCB7B7DF/gi, replacement: "A1B2C3D4E5F6789012345678901234567890ABCD"},
  {regex: /65E7734F5E95DD1AE965EE219EBB2C6B85F04BD0/gi, replacement: "1234567890ABCDEF1234567890ABCDEF12345678"},
  // Generic username last
  {regex: /jagilber/gi, replacement: "cloudadmin"}
];

let totalReplacements = 0;

function replaceInNode(node) {
  if (node.nodeType === Node.TEXT_NODE) {
    let text = node.textContent;
    let changed = false;
    replacements.forEach(({regex, replacement}) => {
      const newText = text.replace(regex, replacement);
      if (newText !== text) {
        text = newText;
        changed = true;
      }
    });
    if (changed) {
      node.textContent = text;
      totalReplacements++;
    }
  } else if (node.nodeType === Node.ELEMENT_NODE) {
    // Handle attributes
    ['aria-label', 'title', 'placeholder', 'value', 'data-original-title'].forEach(attr => {
      if (node.hasAttribute(attr)) {
        let val = node.getAttribute(attr);
        replacements.forEach(({regex, replacement}) => {
          val = val.replace(regex, replacement);
        });
        node.setAttribute(attr, val);
      }
    });
    
    // Handle input/textarea values
    if ((node.tagName === 'INPUT' || node.tagName === 'TEXTAREA') && node.value) {
      let val = node.value;
      replacements.forEach(({regex, replacement}) => {
        val = val.replace(regex, replacement);
      });
      node.value = val;
    }
    
    Array.from(node.childNodes).forEach(child => replaceInNode(child));
  }
}

replaceInNode(document.body);

// Handle Monaco editors (Azure Portal JSON editor)
let monacoEditorsModified = 0;
const editors = document.querySelectorAll('.monaco-editor');

editors.forEach(editorElement => {
  // Target view lines container
  const viewLines = editorElement.querySelector('.view-lines');
  if (viewLines) {
    const lines = viewLines.querySelectorAll('.view-line');
    
    lines.forEach(line => {
      // Get the full HTML of the line
      let lineHTML = line.innerHTML;
      let originalHTML = lineHTML;
      
      // Apply replacements to the HTML (partial patterns work across span boundaries in text)
      replacements.forEach(({regex, replacement}) => {
        lineHTML = lineHTML.replace(regex, replacement);
      });
      
      // If changed, replace the HTML (preserves span structure)
      if (lineHTML !== originalHTML) {
        line.innerHTML = lineHTML;
        monacoEditorsModified++;
        totalReplacements++;
      }
    });
  }
  
  // Also modify hidden textarea (Monaco's input area)
  const textarea = editorElement.querySelector('textarea.inputarea');
  if (textarea && textarea.value) {
    let originalValue = textarea.value;
    let value = originalValue;
    
    replacements.forEach(({regex, replacement}) => {
      value = value.replace(regex, replacement);
    });
    
    if (value !== originalValue) {
      textarea.value = value;
      monacoEditorsModified++;
    }
  }
});

console.log(`✓ Sanitized ${totalReplacements} items, ${monacoEditorsModified} Monaco spans in iframe`);
