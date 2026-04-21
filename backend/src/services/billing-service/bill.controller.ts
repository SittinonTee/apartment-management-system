import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
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
		const success = await billService.approveBill(Number(billId));

		if (!success) {
			throw new AppError("ไม่พบข้อมูลบิล หรือดำเนินการไม่สำเร็จ", 404);
		}

		res.status(200).json({
			status: "success",
			message: "ยืนยันการชำระเงินสำเร็จ",
		});
	} catch (error) {
		next(error);
	}
};
