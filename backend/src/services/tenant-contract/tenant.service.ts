import pool from "../database";

export class TenantService {
	/**
	 * ดึงรายการสัญญาทั้งหมด (สำหรับหน้า List ใน Flutter)
	 */
	static async getMyContracts(userId: number) {
		try {
			// ดึงข้อมูลจาก View ที่เราสร้างไว้ (vw_contract_details)
			const [rows]: any = await pool.query(
				`SELECT * FROM vw_contract_details WHERE user_id = ? ORDER BY start_date DESC`,
				[userId],
			);

			// คืนค่าเป็น Array ของข้อมูลสัญญา
			return rows;
		} catch (error) {
			console.error("[TenantService] Error in getMyContracts:", error);
			throw new Error("ไม่สามารถดึงข้อมูลรายการสัญญาได้");
		}
	}

	/**
	 * ดึงรายละเอียดสัญญาฉบับเดียว (สำหรับหน้า Detail ใน Flutter)
	 */
	static async getContractDetails(userId: number, contractId: number) {
		try {
			const [rows]: any = await pool.query(
				`SELECT * FROM vw_contract_details WHERE user_id = ? AND contracts_id = ?`,
				[userId, contractId],
			);

			// ถ้าไม่เจอข้อมูล ให้ส่ง null กลับไปเพื่อให้ Controller แจ้ง 404
			if (rows.length === 0) {
				return null;
			}

			// ส่งข้อมูล Object ตัวแรกกลับไป
			return rows[0];
		} catch (error) {
			console.error("[TenantService] Error in getContractDetails:", error);
			throw new Error("ไม่สามารถดึงรายละเอียดสัญญาได้");
		}
	}
}
