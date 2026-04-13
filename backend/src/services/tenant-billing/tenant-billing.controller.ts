import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
import * as tenantBillingService from "./tenant-billing.service";

/**
 * ดึงข้อมูลบิลของผู้เช่า
 */
export const getMyBills = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่", 401);
		}

		const bills = await tenantBillingService.getMyBills(userId);

		res.status(200).json({
			status: "success",
			message: "ดึงข้อมูลบิลสำเร็จ",
			data: bills,
		});
	} catch (error) {
		next(error);
	}
};

/**
 * แจ้งชำระเงิน
 */
export const processPayment = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่", 401);
		}

		// รับ billId จาก params เพื่อให้ตรงกับ Flutter
		const { billId } = req.params;

		// บันทึกการจ่ายเงิน
		const success = await tenantBillingService.processPayment(Number(billId));

		if (!success) {
			throw new AppError("ไม่พบข้อมูลบิล หรือดำเนินการไม่สำเร็จ", 404);
		}

		res.status(200).json({
			status: "success",
			message: "แจ้งชำระเงินสำเร็จแล้ว รอการตรวจสอบ",
		});
	} catch (error) {
		next(error);
	}
};
