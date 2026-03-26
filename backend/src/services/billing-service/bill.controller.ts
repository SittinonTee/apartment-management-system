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
