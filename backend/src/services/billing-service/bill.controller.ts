import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
import pool from "../database";
import { sendPushNotification } from "../notification-service/notification.service";
import * as billService from "./bill.service";

export const getMyBills = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งาน", 401);
		}

		const bills = await billService.getBillsByUserId(userId);

		res.status(200).json({
			status: "success",
			data: bills,
		});
	} catch (error) {
		next(error);
	}
};

export const getAllBills = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const bills = await billService.getAllBills();

		res.status(200).json({
			status: "success",
			data: bills,
		});
	} catch (error) {
		next(error);
	}
};

export const approveBill = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const { billId } = req.params;
		const adminUserId = req.user?.id;

		if (!adminUserId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งานในระบบ", 401);
		}

		// ดึงข้อมูลผู้เช่าเพื่อส่งแจ้งเตือนภายหลัง
		const [billInfoRows] = (await pool.query(
			"SELECT c.user_id, b.bill_month FROM Bills b INNER JOIN Contracts c ON b.contract_id = c.contracts_id WHERE b.bills_id = ?",
			[billId],
		)) as [{ user_id: number; bill_month: string }[], unknown];

		let adminName = `Admin ${adminUserId}`;
		try {
			// ลองดึงชื่อจริง (Firstname) ลองทั้ง Users และ users
			const [userRows] = (await pool.query(
				"SELECT firstname FROM Users WHERE user_id = ?",
				[adminUserId],
			)) as [{ firstname: string }[], unknown];

			if (userRows.length > 0 && userRows[0].firstname) {
				adminName = userRows[0].firstname;
			}
		} catch (dbErr) {
			console.error("[DB Error] Failed to fetch admin firstname:", dbErr);
			// ถ้า Users ไม่ผ่าน ลอง users ตัวเล็ก
			try {
				const [userRowsLower] = (await pool.query(
					"SELECT firstname FROM users WHERE user_id = ?",
					[adminUserId],
				)) as [{ firstname: string }[], unknown];
				if (userRowsLower.length > 0 && userRowsLower[0].firstname) {
					adminName = userRowsLower[0].firstname;
				}
			} catch (e) {
				console.error(
					"[DB Error] Failed to fetch admin firstname (lowercase table):",
					e,
				);
			}
		}

		const success = await billService.approveBill(Number(billId), adminName);

		if (!success) {
			throw new AppError("ไม่พบบิลที่ระบุ หรือดำเนินการไม่สำเร็จ", 404);
		}

		// ส่งแจ้งเตือนลูกบ้าน
		if (billInfoRows.length > 0) {
			const billInfo = billInfoRows[0];
			await sendPushNotification(
				billInfo.user_id,
				"✅ ยืนยันการชำระเงิน",
				`บิลประจำเดือน ${billInfo.bill_month} ของคุณได้รับการอนุมัติแล้ว ขอบคุณค่ะ`,
				{ type: "bill", id: String(billId), status: "paid" },
			);
		}

		res.status(200).json({
			status: "success",
			message: "อนุมัติบิลเรียบร้อยแล้ว",
			adminName: adminName,
		});
	} catch (error) {
		console.error("[Approve Bill Fatal Error]:", error);
		next(error);
	}
};

export const rejectBill = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const { billId } = req.params;

		// ดึงข้อมูลผู้เช่าเพื่อส่งแจ้งเตือนภายหลัง
		const [billInfoRows] = (await pool.query(
			"SELECT c.user_id, b.bill_month FROM Bills b INNER JOIN Contracts c ON b.contract_id = c.contracts_id WHERE b.bills_id = ?",
			[billId],
		)) as [{ user_id: number; bill_month: string }[], unknown];

		const success = await billService.rejectBill(Number(billId));

		if (!success) {
			throw new AppError("ไม่พบบิลที่ระบุ หรือดำเนินการไม่สำเร็จ", 404);
		}

		// ส่งแจ้งเตือนลูกบ้าน
		if (billInfoRows.length > 0) {
			const billInfo = billInfoRows[0];
			await sendPushNotification(
				billInfo.user_id,
				"❌ การชำระเงินไม่ถูกต้อง",
				`ใบแนบชำระเงินบิลเดือน ${billInfo.bill_month} ของคุณถูกปฏิเสธ กรุณาตรวจสอบและส่งใหม่อีกครั้ง`,
				{ type: "bill", id: String(billId), status: "rejected" },
			);
		}

		res.status(200).json({
			status: "success",
			message: "ปฏิเสธการชำระเงินเรียบร้อยแล้ว บิลกลับสู่สถานะค้างชำระ",
		});
	} catch (error) {
		next(error);
	}
};
