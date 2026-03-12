import type { NextFunction, Request, Response } from "express";
import { AppError } from "../../middlewares/error.middleware";
import * as authService from "./auth.service";
import type { V_LoginForm, V_RegisterForm } from "./config/auth.schema";

export const login = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { email, password } = req.body as V_LoginForm;
		const result = await authService.loginUser(email, password);

		res.status(200).json({
			status: "success",
			message: "เข้าสู่ระบบสำเร็จ",
			data: result,
		});
	} catch (error: any) {
		console.error("Login Error:", error);
		if (
			error.message === "ไม่พบอีเมลผู้ใช้งานในระบบ" ||
			error.message === "รหัสผ่านไม่ถูกต้อง" ||
			error.message === "บัญชีนี้ถูกระงับหรือยังไม่เปิดใช้งาน"
		) {
			next(new AppError(error.message, 401));
		} else {
			next(error);
		}
	}
};

export const logout = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const userId = (req as any).user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งานสำหรับการออกจากระบบ", 400);
		}
		await authService.logoutUser(String(userId));

		res.status(200).json({
			status: "success",
			message: "ออกจากระบบสำเร็จ",
		});
	} catch (error: any) {
		next(error);
	}
};

export const registerUser = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { invite_code, email, password } = req.body as V_RegisterForm;
		const result = await authService.registerUser(invite_code, email, password);

		res.status(200).json({
			status: "success",
			message: "สมัครสมาชิกสำเร็จ",
			data: result,
		});
	} catch (error: any) {
		console.error("Register Error:", error);
		if (error.message === "ไม่มีโค้ดเชิญนี้ในระบบ หรือ โค้ดไม่ถูกต้อง") {
			next(new AppError(error.message, 401));
		} else {
			next(error);
		}
	}
};
