import type { NextFunction, Request, Response } from "express";
<<<<<<< HEAD
import config from "../services/config";
=======
>>>>>>> origin/setup

// สร้าง Custom Error ของระบบ
export class AppError extends Error {
	public statusCode: number;
	public status: string;
	public isOperational: boolean;

	constructor(message: string, statusCode: number) {
		super(message);
		this.statusCode = statusCode;
		this.status = `${statusCode}`.startsWith("4") ? "fail" : "error"; // 4xx = fail (ฝั่ง User ส่งมาผิด), 5xx = error (Server พังเอง)
		this.isOperational = true;

		Error.captureStackTrace(this, this.constructor);
	}
}

// ตรวจจับ Error ระดับ Global
export const globalErrorHandler = (
<<<<<<< HEAD
	error: unknown,
=======
	err: any,
>>>>>>> origin/setup
	req: Request,
	res: Response,
	next: NextFunction,
): void => {
<<<<<<< HEAD
	const err = error as Error & {
		statusCode?: number;
		status?: string;
		isOperational?: boolean;
		stack?: string;
	};
	const statusCode = err.statusCode || 500;
	const status = err.status || "error";

	if (config.node_env === "development") {
		res.status(statusCode).json({
			status: status,
=======
	err.statusCode = err.statusCode || 500;
	err.status = err.status || "error";

	// รันในโหมด 'development'
	if (process.env.NODE_ENV === "development") {
		console.error("ERROR", err.message);
		res.status(err.statusCode).json({
			status: err.status,
>>>>>>> origin/setup
			error: err,
			message: err.message,
			stack: err.stack,
		});
<<<<<<< HEAD
	} else {
		// Production Mode
		if (err.isOperational) {
			res.status(statusCode).json({
				status: status,
				message: err.message,
			});
		} else {
			// Programming or other unknown error: don't leak error details
			console.error("ERROR 💥", error);
			res.status(500).json({
				status: "error",
				message: "เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์",
=======
	}

	// รันในโหมด 'production'
	else {
		//มาจาก function AppError ที่เราสร้างขึ้นมา
		if (err.isOperational) {
			res.status(err.statusCode).json({
				status: err.status,
				message: err.message,
			});
		}
		// มาจาก err อะไรก็ไม่รู้ที่เราไม่ระบุ
		else {
			console.error("ERROR", err);
			res.status(500).json({
				status: "error",
				message: "Something went very wrong!",
>>>>>>> origin/setup
			});
		}
	}
};
