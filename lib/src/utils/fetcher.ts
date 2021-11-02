import got from 'got';
import dedent from 'ts-dedent';
import { packageJson } from './package';

const token = process.env.TOKEN;
const password = process.env.PASSWORD;

if (typeof token !== "string") {
  throw new Error("An invalid token was received.");
}
if (typeof password !== "string") {
  throw new Error("An invalid password was received.");
}

const libVersion = packageJson.version;
const libRepository = packageJson.repository;
const userAgent = `vertabelo-latex/v${libVersion} (${libRepository})`;

const createAuthHeader = (token: string, password: string): string => {
  const auth = `${token}:${password}`;
  const buff = Buffer.from(auth);
  return `Basic ${buff.toString("base64")}`;
};

export const fetchXML = async (id: string): Promise<string> => {
  const auth = createAuthHeader(token, password);
  const res = await got(`https://my.vertabelo.com/api/xml/${id}`, {
    headers: {
      'User-Agent': userAgent,
      'Authorization': auth,
    },
  });
  if (res.statusCode !== 200) {
    try {
      const json = JSON.parse(res.body);
      throw new Error(dedent`
        An error ocurred while fetching from Vertabelo's API.
        
        HTTP Error ${res.statusCode}: ${json.message}
      `);
    } catch (err) {
      throw new Error(dedent`
        An error ocurred while fetching from Vertabelo's API.
        
        HTTP Error ${res.statusCode}

        Response body couldn't be parsed:
        ${res.body}
      `);
    }
  }
  return res.body;
};
