// entire file content ...
// ... goes in between

const args = process.argv.slice(2);
const [inputFile, outputFile] = args;

const fs = require('fs');

fs.readFile(inputFile, 'utf8', (err, data) => {
  if (err) {
    console.error(err);
    return;
  }
  const lines = data.split('\n');
  const output = lines.map((line) => {
    const [name, email] = line.split(',');
    return `${name} <${email}>`;
  });
  fs.writeFile(outputFile, output.join('\n'), (err) => {
    if (err) {
      console.error(err);
      return;
    }
    console.log(`File saved to ${outputFile}`);
  });
});
