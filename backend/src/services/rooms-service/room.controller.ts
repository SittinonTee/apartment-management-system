import type { NextFunction, Request, Response } from "express";
import * as roomService from "./room.service";

export const addRoom = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const result = await roomService.addRoom(req.body);

		res.status(201).json({
			status: "success",
			message: "เพิ่มห้องพักสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const getAllRooms = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const result = await roomService.getAllRooms();
		res.status(200).json({
			status: "success",
			message: "ดึงข้อมูลห้องพักทั้งหมดสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const updateRoomStatus = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { id } = req.params;
		const { status } = req.body;
		const result = await roomService.updateRoomStatus(Number(id), status);

		res.status(200).json({
			status: "success",
			message: "อัปเดตสถานะห้องพักสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};

export const deleteRoom = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const { id } = req.params;
		const result = await roomService.deleteRoom(Number(id));

		res.status(200).json({
			status: "success",
			message: "ลบห้องพักสำเร็จ",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};
