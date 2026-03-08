#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const repoRoot = process.cwd();
const branchArg = process.argv.find((arg) => arg.startsWith('--branch='));
const branchName = (branchArg && branchArg.split('=')[1]) || 'feature/auto-push';

const ignoredPrefixes = [
  '.git/',
  'node_modules/',
  'build/',
  '.dart_tool/',
  '.next/',
  'web-storefront/.next-dev/',
  'backend/node_modules/',
];

const sensitivePatterns = [
  /(^|\/)\.env(\..*)?$/i,
  /(^|\/)kashair\.env$/i,
  /(^|\/)website-login-info\.md$/i,
  /(^|\/)id_rsa$/i,
  /\.pem$/i,
  /\.key$/i,
];

const toPosix = (value) => value.split(path.sep).join('/');

const run = (command, options = {}) => execSync(command, {
  cwd: repoRoot,
  stdio: ['ignore', 'pipe', 'pipe'],
  encoding: 'utf8',
  ...options,
}).trim();

const ensureBranch = () => {
  const exists = execSync(`git show-ref --verify --quiet refs/heads/${branchName}`, {
    cwd: repoRoot,
    stdio: 'ignore',
  });
  if (exists === undefined) {
    run(`git checkout ${branchName}`);
  }
};

const shouldIgnore = (filePath) => {
  const normalized = toPosix(filePath);
  return ignoredPrefixes.some((prefix) => normalized.startsWith(prefix));
};

const isSensitive = (file) => sensitivePatterns.some((pattern) => pattern.test(file));

const autoPush = () => {
  try {
    const modified = run('git diff --name-only');
    const untracked = run('git ls-files --others --exclude-standard');
    const changedFiles = [...new Set([
      ...modified.split('\n').map((file) => file.trim()),
      ...untracked.split('\n').map((file) => file.trim()),
    ])]
      .filter(Boolean)
      .map((file) => toPosix(file));

    if (!changedFiles.length) return;

    const allowed = changedFiles.filter((file) => !shouldIgnore(file));
    if (!allowed.length) return;

    const nonSensitive = allowed.filter((file) => !isSensitive(file));
    if (nonSensitive.length !== allowed.length) {
      console.log('[auto-push] Sensitive files ignored.');
    }
    if (!nonSensitive.length) return;

    const addCmd = `git add ${nonSensitive.map((file) => `'${file.replace(/'/g, `'"'"'`)}'`).join(' ')}`;
    run(addCmd);

    try {
      run('git diff --cached --quiet');
      return;
    } catch (_) {
      // staged changes exist
    }

    const msg = `chore(auto): sync ${new Date().toISOString()}`;
    run(`git commit -m "${msg}"`);

    try {
      run(`git push origin ${branchName}`);
      console.log(`[auto-push] Pushed to ${branchName}`);
    } catch (error) {
      console.log(`[auto-push] Push failed: ${error.message}`);
    }
  } catch (error) {
    console.log(`[auto-push] Error: ${error.message}`);
  }
};

const start = () => {
  try {
    run('git rev-parse --is-inside-work-tree');
  } catch (error) {
    console.error('Run this from inside your git repository.');
    process.exit(1);
  }

  try {
    run(`git checkout -b ${branchName}`);
  } catch (_) {
    ensureBranch();
  }

  console.log(`[auto-push] Watching for changes on branch ${branchName}...`);

  autoPush();

  let timer = null;
  fs.watch(repoRoot, { recursive: true }, (eventType, filename) => {
    if (!filename) return;
    if (shouldIgnore(filename)) return;
    if (timer) clearTimeout(timer);
    timer = setTimeout(autoPush, 1200);
  });
};

start();
