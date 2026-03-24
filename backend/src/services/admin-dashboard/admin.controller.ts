import type { NextFunction, Request, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import * as adminService from "./admin.service";

export const getUserData = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const result = await adminService.getUserData();

		res.status(200).json({
			status: "success",
			message: "ข้อมูลผู้ใช้ทั้งหมดสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const getAvailableRooms = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const result = await adminService.getAvailableRooms();
		res.status(200).json({
			status: "success",
			message: "ดึงข้อมูลห้องว่างสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const getRates = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const result = await adminService.getRates();
		res.status(200).json({
			status: "success",
			message: "ดึงข้อมูลเรทราคาสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const addTenant = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const adminId = req.user?.id;
		const result = await adminService.addTenant(req.body, adminId);

		res.status(200).json({
			status: "success",
			message: "เพิ่มผู้เช่าใหม่สำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};
