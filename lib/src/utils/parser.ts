import parser from 'fast-xml-parser';
import he from 'he';
import dedent from 'ts-dedent';
import chalk from 'chalk';
import { Vertabelo } from './transform';

export const parseXML = (xml: string): Vertabelo => {
  const validation = parser.validate(xml, {
    allowBooleanAttributes: true,
  });
  
  if (validation !== true) {
    const { err } = validation;
    const prefix = chalk.gray(`C${err.code} ${err.line}:${err.col}`);
    throw new Error(dedent`
      ${prefix} Unable to parse XML: ${err.msg}
    `);
  }

  const parsed = parser.parse(xml, {
    attributeNamePrefix: '_',
    ignoreNameSpace: true,
    ignoreAttributes: false,
    allowBooleanAttributes: true,
    parseNodeValue: true,
    parseAttributeValue: false,
    arrayMode: false,
    tagValueProcessor: (value) => he.decode(value),
    attrValueProcessor: (value) => he.decode(value, { isAttributeValue: true })
  });

  const vertabelo = parsed as Vertabelo;
  
  if (vertabelo.DatabaseModel._VersionId !== "2.4") {
    throw new Error(`Unknown model version: ${vertabelo.DatabaseModel._VersionId}`);
  }

  return vertabelo;
};

export interface AttributeDescription {
  description: string,
  range?: string,
  unit?: string,
  restrictions?: string,
}

type AttributeKey = keyof Omit<AttributeDescription, 'description'>;

export const isAttributeKey = (value: string): value is AttributeKey => {
  return value === "range" || value === "unit" || value === "restrictions";
};

export const parseAttributeDescription = (description: string): AttributeDescription => {
  const trimmed = description.trim();
  const lines = trimmed.split('\n');
  const attr: AttributeDescription = {
    description: "",
  };
  for (const line of lines) {
    if (line.trim().length === 0) {
      continue;
    }
    if (line.includes(' = ')) {
      const split = line.split(' = ');
      if (split.length !== 2) continue;
      const key = split[0].toLowerCase().trim();
      if (!isAttributeKey(key)) continue;
      attr[key] = split[1].trim().replace('\\=', '=');
      continue;
    }
    if (attr.description.length === 0) {
      attr.description = line.trim().replace('\\=', '=');
    }
  }
  return attr;
};
