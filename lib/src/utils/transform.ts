import dedent from 'ts-dedent';

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

const escapeValue = (value: string) => {
  return value.replace(/([_])/g, "\\$1");
};

export const createColumn = (column: TableColumn): string => {
  const { Name, Type, Description } = column;
  if (Description.length === 0) {
    return `\\attribute{${escapeValue(Name)}}{${escapeValue(Type)}}{}`;
  }

  return dedent`
    \\attribute{${escapeValue(Name)}}{${escapeValue(Type)}}{
      ${escapeValue(Description)}
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

export const createDocument = (content: string): string => {
  return dedent`
    \\documentclass[../main.tex]{subfiles}

    \\graphicspath{{\\subfix{../images/}}}
    
    \\begin{document}
      
    ${content}
    
    \\end{document}
  `;
};
