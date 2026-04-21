import type { ResultSetHeader } from "mysql2/promise";
import pool from "../database";
import type { Bill } from "./config/type";

export const getBillsByUserId = async (userId: number): Promise<Bill[]> => {
	const query = `
        SELECT 
            b.*,
            rt.rate_room,
            rt.rate_water,
            rt.rate_electric
        FROM Bills b
        INNER JOIN Contracts c ON b.contract_id = c.contracts_id
        LEFT JOIN Rate rt ON b.rate_id = rt.rate_id
        WHERE c.user_id = ? AND c.status = 'ACTIVE'
        ORDER BY b.created_at DESC
        LIMIT 5
    `;
	const [rows] = (await pool.query(query, [userId])) as [Bill[], unknown];
	return rows;
};

export async function getAllBills(): Promise<Bill[]> {
	const query = `SELECT * FROM vw_bill_details`;
	const [rows] = (await pool.query(query)) as [Bill[], unknown];
	return rows;
}

export async function approveBill(billId: number): Promise<boolean> {
	const query = `UPDATE Bills SET status = 'PAID' WHERE bills_id = ?`;
	const [result] = await pool.query<ResultSetHeader>(query, [billId]);
	return result.affectedRows > 0;
}
