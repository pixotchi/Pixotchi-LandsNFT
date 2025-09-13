const fs = require('fs');
const path = require('path');

function convertJsonToTypeScriptAbi(inputPath, outputPath) {
    // Read the input JSON file
    fs.readFile(inputPath, 'utf8', (err, data) => {
        if (err) {
            console.error('Error reading input file:', err);
            return;
        }

        try {
            // Parse the JSON data
            const abiData = JSON.parse(data);

            // Create the TypeScript content
            const tsContent = `export const abi = ${JSON.stringify(abiData, null, 2)} as const;\n`;

            // Write the TypeScript content to the output file
            fs.writeFile(outputPath, tsContent, (err) => {
                if (err) {
                    console.error('Error writing output file:', err);
                    return;
                }
                console.log(`Successfully converted ${inputPath} to ${outputPath}`);
            });
        } catch (parseError) {
            console.error('Error parsing JSON:', parseError);
        }
    });
}

// Check if the correct number of arguments is provided
if (process.argv.length !== 4) {
    console.log('Usage: node script.js <input_json_path> <output_ts_path>');
    process.exit(1);
}

// Get input and output paths from command line arguments
const inputPath = path.resolve(process.argv[2]);
const outputPath = path.resolve(process.argv[3]);

// Run the conversion
convertJsonToTypeScriptAbi(inputPath, outputPath);