import * as mysql from "mysql2/promise";
import config from "./config";

const dbUrl = config.db.tidepool.DATABASE_URL as string;
const separator = dbUrl.includes("?") ? "&" : "?";
// บังคับ Timezone เป็น +07:00 (ต้องใช้ %2B แทนเครื่องหมาย + ใน URL)
export const pool = mysql.createPool(`${dbUrl}${separator}timezone=%2B07:00`);
export default pool;
