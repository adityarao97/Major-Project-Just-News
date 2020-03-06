const path = require('path');
const fs = require('fs');
const solc = require('solc');

const newsPath = path.resolve(__dirname, 'contracts', 'JustNewsUpdated.sol');

const source = fs.readFileSync(newsPath, 'utf8');

module.exports = solc.compile(source, 1).contracts[':JustNews'];
