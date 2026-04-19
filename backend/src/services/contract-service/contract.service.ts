import pool from "../database";
import type { Contract } from "./config/type";

export const getContractByUserId = async (userId: number) => {
	const query = `
        SELECT 
            c.*, 
            r.room_number, 
            r.floor, 
            rt.rate_room, 
            rt.rate_water, 
            rt.rate_electric,
            u.firstname,
            u.lastname,
            LEFT(r.room_number, 1) AS building
        FROM Contracts c
        LEFT JOIN Room r ON c.room_id = r.room_id
        LEFT JOIN Rate rt ON c.rate_id = rt.rate_id
        LEFT JOIN Users u ON c.user_id = u.user_id
        WHERE c.user_id = ? AND c.status = 'ACTIVE'
        LIMIT 1

    `;
	const [rows] = (await pool.query(query, [userId])) as [Contract[], unknown];
	console.log(rows[0]);
	return rows[0] || null;
};
