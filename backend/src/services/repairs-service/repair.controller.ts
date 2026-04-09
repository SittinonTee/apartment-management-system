import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import { AppError } from "../../middlewares/error.middleware";
import type { CreateRepairRequest } from "./config/type";
import * as repairService from "./repair.service";

export const getMyRepairs = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งาน", 401);
		}

		const repairs = await repairService.getRepairsByUserId(userId);

		res.status(200).json({
			status: "success",
			data: repairs,
		});
	} catch (error) {
		next(error);
	}
};

export const getAllRepairs = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const repairs = await repairService.getAllRepairs();

		res.status(200).json({
			status: "success",
			data: repairs,
		});
	} catch (error) {
		next(error);
	}
};

export const createRepair = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			throw new AppError("ไม่พบข้อมูลผู้ใช้งาน", 401);
		}

		const { category_id, head_repairs, description, preferred_time } = req.body;

		if (!category_id || !head_repairs || !description || !preferred_time) {
			throw new AppError("ข้อมูลไม่ครบถ้วน กรุณากรอกข้อมูลให้ครบ", 400);
		}

		const data: CreateRepairRequest = {
			category_id: Number(category_id),
			head_repairs,
			description,
			preferred_time,
		};

		const insertId = await repairService.createRepairRequest(userId, data);

		res.status(201).json({
			status: "success",
			data: {
				repairsuser_id: insertId,
			},
			message: "แจ้งซ่อมเรียบร้อยแล้ว",
		});
	} catch (error) {
		next(error);
	}
};

export const getCategories = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const categories = await repairService.getCategories();
		console.log(categories);
		res.status(200).json({
			status: "success",
			data: categories,
		});
	} catch (error) {
		next(error);
	}
};

export const updateRepair = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
) => {
	try {
		const updateRepair = await repairService.updateRepair(req.body);

		res.status(200).json({
			status: "success",
			data: {
				repairsuser_id: updateRepair,
			},
			message: "อัปเดตข้อมูลเรียบร้อยแล้ว",
		});
	} catch (error) {
		next(error);
	}
};
