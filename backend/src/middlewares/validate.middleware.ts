import type { NextFunction, Request, Response } from "express";
<<<<<<< HEAD
import { ZodError, type ZodTypeAny } from "zod";
import { AppError } from "./error.middleware";

export const validate = (schema: ZodTypeAny) => {
=======
import { ZodError, type ZodObject } from "zod";
import { AppError } from "./error.middleware";

export const validate = (schema: ZodObject<any, any>) => {
>>>>>>> origin/setup
	// คืนค่าฟังก์ชัน Middleware (ที่มี req, res, next) กลับไปให้ Express ใช้งาน
	return async (
		req: Request,
		res: Response,
		next: NextFunction,
	): Promise<void> => {
		try {
			req.body = await schema.parseAsync(req.body);
			next();
		} catch (error) {
			if (error instanceof ZodError) {
<<<<<<< HEAD
				const errorMessage = error.issues.map((e) => e.message).join(", ");
=======
				const errorMessage = error.issues.map((e: any) => e.message).join(", ");
>>>>>>> origin/setup
				res.status(400).json({
					status: "fail",
					message: errorMessage,
				});
			} else {
				next(new AppError("เกิดข้อผิดพลาดในการตรวจสอบข้อมูล", 500));
			}
		}
	};
};
