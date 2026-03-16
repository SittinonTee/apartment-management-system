import * as mysql from "mysql2/promise";
import config from "./config";
<<<<<<< HEAD

const pool = mysql.createPool(config.db.tidepool.DATABASE_URL as string);
export default pool;

=======

const pool = mysql.createPool(config.db.tidepool.DATABASE_URL as string);
export default pool;
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c
