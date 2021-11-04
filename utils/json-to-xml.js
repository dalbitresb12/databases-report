const fs = require("fs");
const { JSDOM } = require("jsdom");

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

const json = fs.readFileSync("output.json", "utf-8");
/** @type {Table[]} */
const parsed = JSON.parse(json);

const xml = fs.readFileSync("input.xml", "utf-8");

const dom = new JSDOM(xml, {
  contentType: 'text/xml',
});
const { window: { document } } = dom;

const elems = Array.from(document.querySelectorAll("Table Name"));

for (const table of parsed) {
  console.log(`[INFO]: Working on ${table.name}...`);
  const nameElem = elems.find(elem => elem.innerHTML === table.name);
  if (!nameElem) {
    console.warn(`[WARN]: No element found for ${table.name}`);
    continue;
  }
  const tableElem = Array.from(nameElem.parentElement.querySelectorAll("Column Name"))
  for (const column of table.fields) {
    const colNameElem = tableElem.find(elem => elem.innerHTML === column.name);
    if (!colNameElem) {
      console.warn(`[WARN]: No element found for column ${column.name}`);
      continue;
    }
    const descElem = colNameElem.parentElement.querySelector("Description");
    descElem.innerHTML = column.description;
  }
}

const edited = dom.serialize();
fs.writeFileSync("output.xml", edited, "utf-8");
