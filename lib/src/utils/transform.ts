import dedent from 'ts-dedent';
import { parseAttributeDescription } from './parser';

export interface TableColumn {
  _Id: string,
  Name: string,
  Type: string,
  Description: string,
  Nullable: boolean,
  DefaultValue: unknown,
  Properties: {
    Property: {
      Name: string,
      Value: unknown,
    }[],
  }
}

export interface PrimaryKey {
  Name: string,
  Columns: {
    Column: string,
  }
}

export interface Table {
  _Id: string,
  Name: string,
  Description: string,
  Columns: {
    Column: TableColumn[],
  },
  PrimaryKey: PrimaryKey,
}

export interface DatabaseEngine {
  Name: string,
  Version: number,
}

export interface Counter {
  Name: string,
  Value: number,
  Prefix: string,
}

export interface DatabaseModel {
  _VersionId: string,
  Name: string,
  Description: string,
  DatabaseEngine: DatabaseEngine,
  Counters: {
    Counter: Counter[],
  },
  Tables: {
    Table: Table[],
  },
}

export interface Vertabelo {
  DatabaseModel: DatabaseModel,
}

const escapeValue = (value: string): string => {
  return value.replace(/([_%])/g, "\\$1");
};

const deleteEmptyLines = (value: string): string => {
  return value.split('\n').filter(str => str.trim().length > 0).join('\n');
};

export const createColumn = (column: TableColumn): string => {
  const { Name, Type, Description } = column;
  if (Description.length === 0) {
    return `\\attribute{${escapeValue(Name)}}{${escapeValue(Type)}}{}`;
  }
  const parsed = parseAttributeDescription(Description);

  return dedent`
    \\attribute{${escapeValue(Name)}}{${escapeValue(Type)}}{
      ${escapeValue(parsed.description)}
    }
  `;
};

export const createTable = (table: Table): string => {
  const { Name, Columns: { Column: columns } } = table;
  const attributes = columns.map((column) => createColumn(column));
  return dedent`
    \\subsubsection{Tabla ${escapeValue(Name)}}

    \\begin{table}
      ${attributes.join('\n')}
    \\end{table}
  `;
};

export const createDatabase = (vertabelo: Vertabelo): string => {
  const { DatabaseModel: model } = vertabelo;
  const tables = model.Tables.Table.map((table) => createTable(table));
  return dedent`
    \\begin{database}
      ${tables.join('\n\n')}
    \\end{database}
  `;
};

export const createAttributeTable = (column: TableColumn): string => {
  const { Name, Description, Type } = column;
  const parsed = parseAttributeDescription(Description);
  return deleteEmptyLines(dedent`
    \\parbox{0.48\\linewidth}{
      \\begin{table}
        \\name{${escapeValue(Name)}}
        \\definition{${escapeValue(parsed.description)}}
        \\type{${escapeValue(Type)}}
        ${parsed.range ? `\\range{${escapeValue(parsed.range)}}` : ''}
        ${parsed.unit ? `\\unit{${escapeValue(parsed.unit)}}` : ''}
        ${parsed.restrictions ? `\\restrictions{${escapeValue(parsed.restrictions)}}` : ''}
      \\end{table}
    }
  `);
};

export const createAttributeTables = (table: Table): string => {
  const { Name, Columns: { Column: columns } } = table;
  const tables = columns.map(column => createAttributeTable(column));
  const counterName = Name.replace(/[_%]/g, '').toLowerCase();
  return dedent`
    \\subsubsection{Entidad ${escapeValue(Name)}}

    \\begin{attrtables}{${counterName}}
      \\noindent
      ${tables.join('\n\\hfill\n')}
    \\end{attrtables}
  `;
};

export const createDocument = (content: string): string => {
  return dedent`
    \\documentclass[../main.tex]{subfiles}

    \\graphicspath{{\\subfix{../images/}}}
    
    \\begin{document}
      
    ${content}
    
    \\end{document}
  `;
};

export const createTablesDocument = (vertabelo: Vertabelo): string => {
  const database = createDatabase(vertabelo);
  return createDocument(database);
};

export const createAttributesDocument = (vertabelo: Vertabelo): string => {
  const { DatabaseModel: { Tables: { Table: tables } } } = vertabelo;
  const processed = tables.map(table => createAttributeTables(table));
  return createDocument(processed.join('\n\n'));
};
