import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
import * as notificationService from "./notification.service";

export const registerToken = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งาน", 401);
		}

		const { token, device_type } = req.body;

		if (!token) {
			throw new AppError("กรุณาระบุ FCM Token", 400);
		}

		await notificationService.registerFCMToken(
			userId,
			token,
			device_type || "ANDROID",
		);

		res.status(200).json({
			status: "success",
			message: "ลงทะเบียนรับแจ้งเตือนสำเร็จ",
		});
	} catch (error) {
		next(error);
	}
};
