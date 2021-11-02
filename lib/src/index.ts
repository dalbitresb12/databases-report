import 'dotenv/config';
import fs from 'fs/promises';
import consola from 'consola';
import { fetchXML } from './utils/fetcher';
import { parseXML } from './utils/parser';

consola.wrapAll();

const modelId = process.env.MODEL_ID;
if (typeof modelId !== "string") {
  throw new Error("An invalid model ID was received.");
}

const run = async () => {
  const xml = await fetchXML(modelId);
  const parsed = parseXML(xml);
  await fs.writeFile(
    "../output.json",
    JSON.stringify(parsed, null, '  '),
    {
      encoding: 'utf-8',
    }
  );
};

run();
