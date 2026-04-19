import type { NextFunction, Request, Response } from "express";
import { getFirebaseBucket } from "../config/firebase.config";

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

		const bucket = getFirebaseBucket();
		if (!bucket) {
			res.status(500).json({
				status: "error",
				message:
					"ระบบ Firebase ยังไม่ได้ตั้งค่า (Missing config: firebase-service-account.json is missing)",
			});
			return;
		}

		const file = req.file;
		const timestamp = Date.now();
		// Handle Thai characters by interpreting buffer from latin1 to utf-8 (common issue with multer)
		const originalName = Buffer.from(file.originalname, "latin1").toString(
			"utf-8",
		);
		const ext = originalName.split(".").pop();
		// รับชื่อโฟลเดอร์จากหน้าบ้าน (เช่น slips, packages, repairs) ถ้าไม่ส่งมาให้ลงโฟลเดอร์ others
		const targetFolder = req.body.folder || "others";
		const destination = `${targetFolder}/${timestamp}_${Math.round(
			Math.random() * 1000,
		)}.${ext}`;

		const firebaseFile = bucket.file(destination);

		await firebaseFile.save(file.buffer, {
			contentType: file.mimetype,
			metadata: {
				cacheControl: "public, max-age=31536000",
			},
		});

		await firebaseFile.makePublic();
		const publicUrl = `https://storage.googleapis.com/${bucket.name}/${firebaseFile.name}`;

		res.status(200).json({
			status: "success",
			message: "อัพโหลดไฟล์สำเร็จ",
			data: {
				filename: firebaseFile.name,
				url: publicUrl,
			},
		});
	} catch (error) {
		console.error("Upload error:", error);
		next(error);
	}
};
