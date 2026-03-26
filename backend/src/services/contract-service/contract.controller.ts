import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
import * as contractService from "./contract.service";

export const getMyContract = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งาน", 401);
		}

		const contract = await contractService.getContractByUserId(userId);

		if (!contract) {
			return res.status(200).json({
				status: "success",
				message: "ไม่พบสัญญาเช่าที่กำลังใช้งาน",
				data: null,
			});
		}

		res.status(200).json({
			status: "success",
			data: contract,
		});
	} catch (error) {
		next(error);
	}
};
