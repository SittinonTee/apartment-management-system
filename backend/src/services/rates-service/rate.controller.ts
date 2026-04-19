import type { NextFunction, Request, Response } from "express";
import * as rateService from "./rate.service";

export const getAllRates = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const result = await rateService.getAllRates();
		res.status(200).json({
			status: "success",
			message: "ดึงข้อมูลเรทราคาทั้งหมดสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const addRate = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const result = await rateService.addRate(req.body);
		res.status(201).json({
			status: "success",
			message: "เพิ่มเรทราคาใหม่สำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const updateRate = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { id } = req.params;
		const result = await rateService.updateRate(Number(id), req.body);
		res.status(200).json({
			status: "success",
			message: "อัปเดตเรทราคาสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const deleteRate = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { id } = req.params;
		await rateService.deleteRate(Number(id));
		res.status(200).json({
			status: "success",
			message: "ลบเรทราคาสำเร็จ",
		});
	} catch (error) {
		next(error);
	}
};
