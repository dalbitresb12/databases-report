import 'dotenv/config';
import fs from 'fs/promises';
import consola from 'consola';
import { fetchXML } from './utils/fetcher';
import { parseXML } from './utils/parser';
import { createDatabase, createDocument } from './utils/transform';

consola.wrapAll();

const modelId = process.env.MODEL_ID;
if (typeof modelId !== "string") {
  throw new Error("An invalid model ID was received.");
}

const run = async () => {
  const xml = await fetchXML(modelId);
  const parsed = parseXML(xml);
  const database = createDatabase(parsed);
  const document = createDocument(database);
  await fs.mkdir("out/", { recursive: true });
  await fs.writeFile("out/detailed-tables.tex", document, { encoding: 'utf-8' });
};

run();
