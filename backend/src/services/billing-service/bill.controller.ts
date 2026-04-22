import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
import pool from "../database";
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
		const userId = req.user?.id;

		console.log(`[Approve Bill Request] BillID: ${billId}, UserID: ${userId}`);

		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งานในระบบ", 401);
		}

		let adminName = `Admin ${userId}`;
		try {
			// ลองดึงชื่อจริง (Firstname) ลองทั้ง Users และ users
			const [userRows] = (await pool.query(
				"SELECT firstname FROM Users WHERE user_id = ?",
				[userId],
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
					[userId],
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

		console.log(
			`[Approve Bill Execution] Final Admin Name to Save: "${adminName}"`,
		);

		const success = await billService.approveBill(Number(billId), adminName);

		if (!success) {
			throw new AppError("ไม่พบบิลที่ระบุ หรือดำเนินการไม่สำเร็จ", 404);
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

		const success = await billService.rejectBill(Number(billId));

		if (!success) {
			throw new AppError("ไม่พบบิลที่ระบุ หรือดำเนินการไม่สำเร็จ", 404);
		}

		res.status(200).json({
			status: "success",
			message: "ปฏิเสธการชำระเงินเรียบร้อยแล้ว บิลกลับสู่สถานะค้างชำระ",
		});
	} catch (error) {
		next(error);
	}
};
