// backend/src/services/packages-service/packages.controller.ts

import type { Request, Response } from "express";
import * as parcelService from "./packages.service";

interface AuthRequest extends Request {
	user?: {
		id: number;
		[key: string]: unknown;
	};
}

export const createParcel = async (
	req: Request,
	res: Response,
): Promise<void> => {
	try {
		const { name, room_number, parcelsimage_url } = req.body;
		// บันทึกเป็น user_id ของพนักงานที่ล็อกอินอยู่ (ดึงมาเป็นตัวเลขเพื่อส่งเข้า addParcel)
		const adminId = Number((req as AuthRequest).user?.id) || 0;

		if (!name || !room_number) {
			res.status(400).json({ message: "กรุณาระบุชื่อผู้รับ และเลขห้อง" });
			return;
		}

		const result = await parcelService.addParcel(
			{ name, room_number, parcelsimage_url: parcelsimage_url || "" },
			adminId,
		);
		res.status(201).json(result);
	} catch (error) {
		res
			.status(500)
			.json({ message: "ไม่สามารถเพิ่มพัสดุได้", error: (error as Error).message });
	}
};

export const getAdminParcels = async (
	req: Request,
	res: Response,
): Promise<void> => {
	try {
		const status = req.query.status as string;
		const search = req.query.search as string; // ค้นหาชื่อ หรือเลขห้อง

		const parcels = await parcelService.getParcelsAdmin(status, search);
		res.status(200).json(parcels);
	} catch (error) {
		res.status(500).json({
			message: "ข้อผิดพลาดในการดึงข้อมูลพัสดุ",
			error: (error as Error).message,
		});
	}
};

export const getUserParcels = async (
	req: Request,
	res: Response,
): Promise<void> => {
	try {
		// เอา user_id มาจาก Token ของคนที่ทำการ Request
		const userId = Number((req as AuthRequest).user?.id);
		const parcels = await parcelService.getParcelsByUser(userId);

		res.status(200).json(parcels);
	} catch (error) {
		res.status(500).json({
			message: "ข้อผิดพลาดในการดึงข้อมูลพัสดุของลูกบ้าน",
			error: (error as Error).message,
		});
	}
};

export const pickupParcel = async (
	req: Request,
	res: Response,
): Promise<void> => {
	try {
		const parcelId = Number(req.params.id);
		const result = await parcelService.markParcelAsPickedUp(parcelId);

		res.status(200).json(result);
	} catch (error) {
		res.status(400).json({ message: (error as Error).message });
	}
};
