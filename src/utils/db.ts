import mysql from 'mysql2/promise';

const pool = mysql.createPool({
  host: '127.0.0.1',
  user: 'root',
  password: 'Ac661978',
  database: 'mioflow',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

export const db = {
  query: async (sql: string, values?: any[]) => {
    const [rows] = await pool.query(sql, values);
    return rows;
  },

  execute: async (sql: string, values?: any[]) => {
    const [result] = await pool.execute(sql, values);
    return result;
  },

  getConnection: async () => {
    return await pool.getConnection();
  }
};