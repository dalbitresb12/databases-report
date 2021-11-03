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
    parseAttributeValue: true,
    arrayMode: false,
    tagValueProcessor: (value) => he.decode(value),
    attrValueProcessor: (value) => he.decode(value, { isAttributeValue: true })
  });

  return parsed as Vertabelo;
};
