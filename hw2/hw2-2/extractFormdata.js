const cheerio = require('cheerio');

let data;

process.stdin.resume();
process.stdin.setEncoding('utf8');

process.stdin.on('data', function(chunk) {
  data += chunk;
});

process.stdin.on('end', function() {
  const $ = cheerio.load(data);
  const formdata = $('form').serialize();
  console.log(formdata);
});

