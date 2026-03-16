import type { NextFunction, Request, Response } from "express";
import config from "../services/config";

// สร้าง Custom Error ของระบบ
export class AppError extends Error {
	public statusCode: number;
	public status: string;
	public isOperational: boolean;
	public statusCode: number;
	public status: string;
	public isOperational: boolean;

	constructor(message: string, statusCode: number) {
		super(message);
		this.statusCode = statusCode;
		this.status = `${statusCode}`.startsWith("4") ? "fail" : "error"; // 4xx = fail (ฝั่ง User ส่งมาผิด), 5xx = error (Server พังเอง)
		this.isOperational = true;
		constructor(message: string, statusCode: number) {
			super(message);
			this.statusCode = statusCode;
			this.status = `${statusCode}`.startsWith("4") ? "fail" : "error"; // 4xx = fail (ฝั่ง User ส่งมาผิด), 5xx = error (Server พังเอง)
			this.isOperational = true;

			Error.captureStackTrace(this, this.constructor);
		}
		Error.captureStackTrace(this, this.constructor);
	}
}

// ตรวจจับ Error ระดับ Global
export const globalErrorHandler = (
	error: unknown,
	req: Request,
	res: Response,
	next: NextFunction,
): void => {
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
			error: err,
			message: err.message,
			stack: err.stack,
		});
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
			});
		}
	}
};
