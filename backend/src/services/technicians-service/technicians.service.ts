import pool from "../database";

export const TechniciansService = {
	// ดึงรายการแจ้งซ่อมทั้งหมด (Join ข้อมูลห้อง, ผู้เช่า, และเชิงลึกอย่างเบอร์โทร-ชั้น)
	async getAllRepairs() {
		const [rows] = await pool.query(`
			SELECT 
				r.*, 
				u.firstname, 
				u.lastname,
				u.phone,
				rm.room_number,
				rm.floor as room_floor,
				rc.name_category as category_name
			FROM Repairs_user r
			LEFT JOIN Users u ON r.user_id = u.user_id
			LEFT JOIN Contracts c ON u.user_id = c.user_id
			LEFT JOIN Room rm ON c.room_id = rm.room_id
			LEFT JOIN Repair_categories rc ON r.category_id = rc.category_id
			ORDER BY r.created_at DESC
		`);
		return rows;
	},

	// ช่างรับงาน (กดยืนยันจากหน้าแอป)
	async acceptRepair(
		repairId: number,
		technicianId: number,
		scheduledAt: string,
	) {
		const connection = await pool.getConnection();
		try {
			await connection.beginTransaction();

			// 1. อัปเดตสถานะในตารางหลัก (ผู้เช่าแจ้งมา) ให้เป็น 'ASSIGNED'
			await connection.query(
				"UPDATE Repairs_user SET status = 'ASSIGNED' WHERE repairsuser_id = ?",
				[repairId],
			);

			// 2. บันทึกข้อมูลการมอบหมายงานให้ช่างคนนี้ และลงนัดหมาย
			await connection.query(
				"INSERT INTO Repairs_technicians (repairsuser_id, technician_by, scheduled_at, assigned_at) VALUES (?, ?, ?, NOW())",
				[repairId, technicianId, scheduledAt],
			);

			await connection.commit();
			return { success: true, message: "รับงานเรียบร้อยแล้ว" };
		} catch (error) {
			await connection.rollback();
			throw error;
		} finally {
			connection.release();
		}
	},
};
