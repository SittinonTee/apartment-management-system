import mysql from 'mysql2/promise';
import config from './config';

const pool = mysql.createPool(config.db.tidepool.DATABASE_URL!);
export default pool;