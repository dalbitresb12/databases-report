import parser from 'fast-xml-parser';
import dedent from 'ts-dedent';
import chalk from 'chalk';

export const parseXML = (xml: string) => {
  const validation = parser.validate(xml);
  
  if (validation !== true) {
    const { err } = validation;
    const prefix = chalk.gray(`C${err.code} ${err.line}:${err.col}`);
    throw new Error(dedent`
      ${prefix} Unable to parse XML: ${err.msg}
    `);
  }

  return parser.parse(xml);
};
