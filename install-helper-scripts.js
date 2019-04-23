#!/usr/bin/env node

// Methododebugy extracted from: https://stackoverflow.com/a/25023044/818073

const fs = require('fs');
const path = require('path');
const util = require("util");
const writeFile = util.promisify(fs.writeFile);

const Octokit = require('@octokit/rest');

const { GITHUB_AUTH_TOKEN, ENABLE_DEBUG } = process.env;

const debug = (...message) => {
  if (!ENABLE_DEBUG) return;
  const messages = message.join(' ');
  console.debug(`${(new Date()).toISOString()} - ${messages}`);
}

let octokitConfig = {};

if (!GITHUB_AUTH_TOKEN) {
  debug('Running without authenticated requests...');
} else {
  octokitConfig = { ...octokitConfig, auth: GITHUB_AUTH_TOKEN };
}

const octokit = new Octokit(octokitConfig);

const owner = 'jeroenjanssens'
const repo = 'data-science-at-the-command-line'

const getDirectoryContents = async (path) => {
  debug("Getting contents for latest commit")
  const contents =  await octokit.repos.getContents({
    owner,
    repo,
    path,
  });
  return contents.data;
};

const createFile = async (destPath, { name , sha }) => {
  debug(`Getting blob: ${name}`)
  const blob = await octokit.git.getBlob({
    owner,
    repo,
    file_sha: sha,
  });
  const encodedContents = blob.data.content;
  const contents = Buffer.from(encodedContents, 'base64').toString('ascii');
  const filename = path.join(destPath, name);
  debug(`Creating file: ${filename}`);
  await writeFile(filename, contents);
  debug(`File created: ${filename}`);
};

const main = async () => {
  const directoryContents = await getDirectoryContents('tools');
  return Promise.all(directoryContents.map(c => createFile('scripts', c)));
};

(async () => {
  try {
    await main();
  } catch (e) {
    console.error(e);
  }
})();
