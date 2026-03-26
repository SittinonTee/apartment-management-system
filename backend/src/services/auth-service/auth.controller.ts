import type { NextFunction, Request, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
import * as authService from "./auth.service";
import type {
	V_ForgotPasswordForm,
	V_LoginForm,
	V_RegisterForm,
	V_ResetPasswordForm,
} from "./config/auth.schema";

//-----------------------------------------------------------เข้าสู่ระบบ-------------------------------------------------------------
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
	} catch (error) {
		const err = error as Error;
		console.error("Login Error:", err);
		if (
			err.message === "ไม่พบอีเมลผู้ใช้งานในระบบ" ||
			err.message === "รหัสผ่านไม่ถูกต้อง" ||
			err.message === "บัญชีนี้ถูกระงับหรือยังไม่เปิดใช้งาน"
		) {
			next(new AppError(err.message, 401));
		} else {
			next(error);
		}
	}
};
//-----------------------------------------------------------ออกจากระบบ-------------------------------------------------------------
export const logout = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const userId = (req as AuthRequest).user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งานสำหรับการออกจากระบบ", 400);
		}
		await authService.logoutUser(String(userId));

		res.status(200).json({
			status: "success",
			message: "ออกจากระบบสำเร็จ",
		});
	} catch (error) {
		next(error);
	}
};
//-----------------------------------------------------------สมัครสมาชิกบัญชี-------------------------------------------------------------
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
	} catch (error) {
		const err = error as Error;
		if (err.message === "ไม่มีโค้ดเชิญนี้ในระบบ หรือ โค้ดไม่ถูกต้อง") {
			next(new AppError(err.message, 401));
		} else {
			next(err);
		}
	}
};
//-----------------------------------------------------------ลืมรหัสผ่าน-------------------------------------------------------------
export const forgotPassword = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { email } = req.body as V_ForgotPasswordForm;
		const result = await authService.forgotPassword(email);

		res.status(200).json({
			status: "success",
			message: result.message,
			data: { mock_otp: result.mock_otp }, // ค่อยมาลบ mockup
		});
	} catch (error) {
		const err = error as Error;
		console.error("Forgot Password Error:", err);
		if (err.message === "ไม่พบอีเมลผู้ใช้งานในระบบ") {
			next(new AppError(err.message, 404));
		} else {
			next(error);
		}
	}
};
//-----------------------------------------------------------รีเซ็ตรหัสผ่าน-------------------------------------------------------------
export const resetPassword = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { email, otp, new_password } = req.body as V_ResetPasswordForm;
		const result = await authService.resetPassword(email, otp, new_password);

		res.status(200).json({
			status: "success",
			message: result.message,
		});
	} catch (error) {
		const err = error as Error;
		console.error("Reset Password Error:", err);
		if (
			err.message === "ไม่พบอีเมลผู้ใช้งานในระบบ" ||
			err.message === "ไม่พบคำขอรีเซ็ตรหัสผ่าน" ||
			err.message === "รหัส OTP หมดอายุแล้ว กรุณาขอใหม่" ||
			err.message === "รหัส OTP ไม่ถูกต้อง"
		) {
			next(new AppError(err.message, 400));
		} else {
			next(error);
		}
	}
};
