import type { NextFunction, Request, Response } from "express";
import { uploadToFirebase } from "./utils/firebase_upload";

export const uploadFile = async (
	req: Request,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		if (!req.file) {
			res.status(400).json({
				status: "error",
				message: "กรุณาแนบไฟล์ (No file provided)",
			});
			return;
		}

		// รับชื่อโฟลเดอร์จากหน้าบ้าน (เช่น slips, packages, repairs) ถ้าไม่ส่งมาให้ลงโฟลเดอร์ others
		const targetFolder = req.body.folder || "others";

		// เรียกใช้ Utility เพื่ออัพโหลด
		const publicUrl = await uploadToFirebase(req.file, targetFolder);

		res.status(200).json({
			status: "success",
			message: "อัพโหลดไฟล์สำเร็จ",
			data: {
				filename: req.file.filename || req.file.originalname,
				url: publicUrl,
			},
		});
	} catch (error) {
		console.error("Upload error:", error);
		next(error);
	}
};
