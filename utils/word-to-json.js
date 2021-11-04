const fs = require("fs");

/**
 * @typedef Column
 * @property {string} name
 * @property {string} type
 * @property {string} description
 */

/**
 * @typedef Table
 * @property {string} name
 * @property {Column[]} fields 
 */

/**
 * @param {string} text 
 * @returns {Table[]}
 */
const parse = (text) => {
  const lines = text.split('\n');
  /** @type {Table[]} */
  const tables = [];
  /** @type {Table | undefined} */
  let current = undefined;
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.length === 0 || trimmed.startsWith('Column name')) {
      continue;
    }
    if (trimmed.startsWith('Tabla ')) {
      if (current !== undefined) {
        tables.push(current);
      }
      current = {
        name: line.slice(6),
        fields: [],
      };
      continue;
    }
    if (!trimmed.includes('\t')) {
      throw new Error(`Invalid line: ${trimmed}`)
    }
    const data = line.split('\t');
    if (data.length !== 3) {
      throw new Error(`Invalid line: ${trimmed}`)
    }
    current.fields.push({
      name: data[0],
      type: data[1],
      description: data[2],
    });
  }
  tables.push(current);
  return tables;
};

const file = fs.readFileSync("input.txt", "utf-8");
const tables = parse(file);
const json = JSON.stringify(tables, null, '  ');
fs.writeFileSync("output.json", json, "utf-8");
