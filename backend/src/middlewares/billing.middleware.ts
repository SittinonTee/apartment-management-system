import type { NextFunction, Response } from "express";
import type { RowDataPacket } from "mysql2/promise";
import { pool } from "../services/database";
import type { AuthRequest } from "./auth.middleware";

/**
 * Middleware สำหรับตรวจสอบสิทธิ์การเข้าถึงบิล (Bill Access Control)
 * - ต้องเป็นเจ้าของบิลจริง ถึงจะจัดการได้
 * - สถานะบิลต้องไม่ใช่ PAID หรือ CANCELLED ถึงจะกดจ่ายได้
 */
export const verifyBillAccess = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const { billId } = req.params;
		const userId = req.user?.id;

		if (!userId) {
			return res.status(401).json({ message: "กรุณาเข้าสู่ระบบก่อนดำเนินการ" });
		}

		// 1. ค้นหาข้อมูลบิล
		// หมายเหตุ: ใช้ SQL ธรรมดาเพื่อความรวดเร็วในการเช็คสิทธิ์เบื้องต้น
		const [rows] = await pool.query<RowDataPacket[]>(
			"SELECT user_id, status FROM Bills WHERE bills_id = ?",
			[billId],
		);

		if (rows.length === 0) {
			return res.status(404).json({ message: "ไม่พบข้อมูลบิลที่ระบุ" });
		}

		const bill = rows[0];

		// 2. ตรวจสอบความเป็นเจ้าของ (Ownership Check)
		// ถ้าคนล็อกอินไม่ใช่เจ้าของบิล และไม่ใช่ ADMIN ให้ดีดออก
		if (bill.user_id !== userId && req.user?.role !== "ADMIN") {
			return res.status(403).json({
				message: "คุณไม่มีสิทธิ์จัดการบิลใบนี้ (Permission Denied)",
			});
		}

		// 3. ตรวจสอบสถานะบิล (Status Check)
		// ถ้าจ่ายไปแล้ว (PAID) ห้ามแก้ไขข้อมูล/ส่งสลิปซ้ำ
		if (bill.status === "PAID") {
			return res.status(400).json({
				message: "บิลใบนี้ชำระเงินเรียบร้อยแล้ว ไม่สามารถดำเนินการซ้ำได้",
			});
		}

		// ถ้าบิลถูกยกเลิก (CANCELLED) ห้ามยุ่ง
		if (bill.status === "CANCELLED") {
			return res.status(400).json({
				message: "บิลใบนี้ถูกยกเลิกแล้ว ไม่สามารถแจ้งชำระเงินได้",
			});
		}

		// ผ่านทุกด่าน! ทำงานขั้นต่อไป (Controller) ได้
		next();
	} catch (error) {
		console.error("verifyBillAccess Error:", error);
		res.status(500).json({ message: "ระบบตรวจสอบสิทธิ์ขัดข้อง" });
	}
};
