import 'dotenv/config';
import fs from 'fs/promises';
import path from 'path';
import consola from 'consola';
import dedent from 'ts-dedent';
import { fetchXML } from './utils/fetcher';
import { parseXML } from './utils/parser';
import { createDatabase, createDocument } from './utils/transform';

consola.wrapAll();

const modelId = process.env.MODEL_ID;
if (typeof modelId !== "string") {
  throw new Error("An invalid model ID was received.");
}

const parseArgs = (def: string): string => {
  const args = process.argv.slice(2);
  if (args.length === 0) {
    return path.resolve(def);
  }
  return path.resolve(args[0]);
};

const run = async () => {
  try {
    const xml = await fetchXML(modelId);
    const parsed = parseXML(xml);
    const database = createDatabase(parsed);
    const document = createDocument(database);
    const outputDir = parseArgs('out/');
    await fs.mkdir(outputDir, { recursive: true });
    await fs.writeFile(
      path.join(outputDir, 'detailed-tables.tex'),
      document,
      { encoding: 'utf-8' }
    );
  } catch (err) {
    if (err instanceof Error) {
      console.error(err);
      process.exit(1);
    }
    console.error(dedent`
      An unknown error has ocurred: ${err}`
    );
  }
};

run();
