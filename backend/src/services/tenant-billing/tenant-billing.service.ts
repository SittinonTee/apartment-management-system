import type { ResultSetHeader } from "mysql2/promise";
import { pool } from "../database";
import type { BILL_DETAILS } from "./config/tenantBilling.type";

/**
 * ดึงข้อมูลบิลทั้งหมดของผู้เช่าที่ล็อกอินอยู่
 * โดยดึงจาก View vw_bill_details เพื่อให้ได้ยอดรวมที่คำนวณแล้ว
 */
export const getMyBills = async (userId: number): Promise<BILL_DETAILS[]> => {
	const query = `
    SELECT * 
    FROM vw_bill_details 
    WHERE user_id = ? 
    ORDER BY created_at DESC
  `;
	const [rows] = await pool.query<BILL_DETAILS[]>(query, [userId]);
	return rows;
};

export const processPayment = async (billId: number): Promise<boolean> => {
	const mockSlipUrl = "https://example.com/slip_feb.jpg";
	const query = `
    UPDATE Bills 
    SET slipimage_url = ?, 
        payment_date = NOW()
    WHERE bills_id = ?
  `;
	const [result] = await pool.query(query, [mockSlipUrl, billId]);
	return (result as ResultSetHeader).affectedRows > 0;
};
