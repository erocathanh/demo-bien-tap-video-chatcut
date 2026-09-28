#!/usr/bin/env node
// kiem-lo-duong-dan.mjs — find personal home-folder paths (a real user name) before the package goes public.
// Usage (from anywhere):
//   node scripts/kiem-lo-duong-dan.mjs                  scan every tracked text file (working copy)
//   node scripts/kiem-lo-duong-dan.mjs --range A..B     scan only the lines added in commits A..B (e.g. origin/main..HEAD)
//   node scripts/kiem-lo-duong-dan.mjs --self-test      prove the ruler catches every known form and skips masked ones
// Catches, case-insensitive, any user name incl. Vietnamese letters (Đức, Thành):
//   macOS /Users/<name>   Linux /home/<name>   Git Bash /c/Users/<name>
//   Windows C:\Users\<name>, C:/Users/<name>, and JSON-escaped C:\\Users\\<name>
// Skips masked or placeholder forms: /Users/…/x, C:\Users\…\x, /Users/<tên>/x, /Users/$USER, /Users/Shared.
// This file is excluded from its own scan (it contains the test strings).
// Exit: 0 clean · 1 personal path found · 2 usage or git error. Works on macOS, Windows (Git Bash) and Linux.
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const SKILL_DIR = join(dirname(fileURLToPath(import.meta.url)), "..");
const SELF = relative(SKILL_DIR, fileURLToPath(import.meta.url)).split("\\").join("/");

// A name is one path segment: stop at separators, whitespace, quotes, brackets, "…" and "*".
const NAME = String.raw`([^\/\\\s"'` + "`" + String.raw`<>…*(){}\[\],;:|]+)`;
const PATTERNS = [
  new RegExp(String.raw`(?:^|[^A-Za-z0-9])\/Users\/` + NAME, "giu"),                       // macOS
  new RegExp(String.raw`(?:^|[^A-Za-z0-9])\/[a-z]\/Users\/` + NAME, "giu"),                // Git Bash /c/Users/<name>
  new RegExp(String.raw`[A-Za-z]:(?:\\{1,2}|\/)Users(?:\\{1,2}|\/)` + NAME, "giu"),           // Windows, incl. JSON-escaped
  new RegExp(String.raw`(?:^|[^A-Za-z0-9])\/home\/` + NAME, "giu"),                          // Linux
];
const NOT_A_PERSON = new Set(["shared", "public", "default", "default user", "all users", "guest"]);

function findIn(line) {
  const hits = [];
  for (const re of PATTERNS) {
    re.lastIndex = 0;
    let m;
    while ((m = re.exec(line)) !== null) {
      const name = m[1];
      if (/^[$%]/.test(name) || NOT_A_PERSON.has(name.toLowerCase())) continue;
      hits.push(name);
    }
  }
  return [...new Set(hits)]; // one line can match two patterns (C:/Users/<name>)
}

function git(args) {
  return execFileSync("git", ["-C", SKILL_DIR, ...args], { encoding: "utf8", maxBuffer: 256 * 1024 * 1024 });
}

function selfTest() {
  const mustCatch = [
    "a /Users/bob/x.mp4", "b HOME=/Users/bob", 'c "/Users/bob"', "d /Users/Đức/x", "e /Users/Thành/x",
    "f C:\\Users\\bob\\x.mp4", 'g {"p":"C:\\\\Users\\\\bob\\\\x.mp4"}', "h C:/Users/bob/x", "i C:/Users/bob",
    "j C:\\Users\\Đức\\AppData", "k /c/Users/Đức/x", "l /c/Users/bob/Downloads", "m /home/lan/x", "n c:\\users\\Minh",
  ];
  const mustSkip = [
    "o C:\\Users\\…\\chatcut-…-waveform-….txt", "p /c/Users/…", "q /Users/…/x", "r /Users/<tên>/x",
    "s C:\\Users\\<tên>\\.claude", "t /Users/$USER/x", "u /Users/Shared/x", "v %USERPROFILE%\\.claude\\skills",
    "w https://github.com/erocathanh/demo", "x ~/.claude/skills/demo",
  ];
  let bad = 0;
  for (const s of mustCatch) if (findIn(s).length === 0) { console.log("MISSED  " + s); bad++; }
  for (const s of mustSkip) if (findIn(s).length !== 0) { console.log("FALSE HIT  " + s + "  ->  " + findIn(s)); bad++; }
  console.log(`self-test: ${mustCatch.length} must be caught, ${mustSkip.length} must be skipped · errors ${bad}`);
  console.log(bad === 0 ? "RESULT PASS" : "RESULT FAIL");
  process.exit(bad === 0 ? 0 : 1);
}

function scanTree() {
  const files = git(["ls-files", "-z"]).split("\0").filter(Boolean).filter((f) => f !== SELF);
  const found = [];
  for (const f of files) {
    let buf;
    try { buf = readFileSync(join(SKILL_DIR, f)); } catch { continue; }
    if (buf.subarray(0, 8192).includes(0)) continue; // binary
    buf.toString("utf8").split(/\r?\n/).forEach((line, i) => {
      for (const name of findIn(line)) found.push(`${f}:${i + 1}: «${name}»  ${line.trim().slice(0, 140)}`);
    });
  }
  return { found, scope: `${files.length} tracked files` };
}

function scanRange(range) {
  const out = git(["log", "-p", "--no-color", "--no-ext-diff", "--format=commit %h", range]);
  const found = [];
  let commit = "", file = "";
  for (const line of out.split(/\r?\n/)) {
    if (line.startsWith("commit ")) { commit = line.slice(7); continue; }
    if (line.startsWith("+++ ")) { file = line.slice(4).replace(/^b\//, ""); continue; }
    if (!line.startsWith("+") || file === SELF) continue;
    for (const name of findIn(line.slice(1))) found.push(`${commit} ${file}: «${name}»  ${line.slice(1).trim().slice(0, 140)}`);
  }
  return { found, scope: `lines added in ${range}` };
}

const args = process.argv.slice(2);
if (args[0] === "--self-test") selfTest();
let res;
try {
  if (args.length === 0) res = scanTree();
  else if (args[0] === "--range" && args[1]) res = scanRange(args[1]);
  else { console.log("usage: node scripts/kiem-lo-duong-dan.mjs [--range A..B | --self-test]"); process.exit(2); }
} catch (e) {
  console.log("FAIL git error: " + String(e.message).split("\n")[0]);
  process.exit(2);
}
for (const h of res.found) console.log("FOUND  " + h);
console.log(`scanned ${res.scope} · personal paths found: ${res.found.length}`);
console.log(res.found.length === 0 ? "RESULT PASS" : "RESULT FAIL");
process.exit(res.found.length === 0 ? 0 : 1);
