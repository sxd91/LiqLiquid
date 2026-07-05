const fs = require("fs");
const path = require("path");

const ROOT = __dirname;

const EXTS = [".dart", ".yaml", ".yml", ".xml", ".gradle", ".kts", ".kt", ".java",
  ".cc", ".cpp", ".h", ".plist", ".xcconfig", ".pbxproj", ".md", ".ps1",
  ".cmake", ".txt", ".rc", ".prerm", ".postrm", ".postinst", ".control"];

const EXCLUDE_DIRS = [".git", "build", ".dart_tool", "ephemeral", ".flutter-plugins"];

const REPLACEMENTS = [
  [/piliplus/gi, "liqliquid"],
  [/liquidpiliplus/gi, "liqliquid"],
];

let changed = 0;

function walk(dir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const fp = path.join(dir, e.name);
    if (e.isDirectory()) {
      if (!EXCLUDE_DIRS.some(d => fp.includes(d))) walk(fp);
    } else if (e.isFile()) {
      const ext = path.extname(e.name).toLowerCase();
      const base = path.basename(e.name);
      if (EXTS.includes(ext) || EXTS.some(x => base.endsWith(x))) {
        let content = fs.readFileSync(fp, "utf8");
        let modified = false;
        for (const [re, replacement] of REPLACEMENTS) {
          if (re.test(content)) {
            content = content.replace(re, replacement);
            modified = true;
          }
        }
        if (modified) {
          fs.writeFileSync(fp, content, "utf8");
          changed++;
          console.log("REPLACED:", fp.replace(ROOT + path.sep, ""));
        }
      }
    }
  }
}

walk(ROOT);
console.log(`\nDone. ${changed} files modified.`);