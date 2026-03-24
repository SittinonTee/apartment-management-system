import { createPool } from 'mysql2/promise';
import config from './config';

export const pool = createPool(config.db.tidepool.DATABASE_URL!);