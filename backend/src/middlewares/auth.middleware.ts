import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import config from "../services/config";
import { AppError } from "./error.middleware";
<<<<<<< HEAD
import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import config from "../services/config";
import { AppError } from "./error.middleware";
=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c

// ยังไม่ได้ทดสอบ
export interface TokenPayload {
	id: number; // รหัสพนักงาน
	email: string; // อีเมล
	role: string; // บทบาท
}

export interface AuthRequest extends Request {
	user?: TokenPayload;
<<<<<<< HEAD
	user?: TokenPayload;
=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c
}

export const verifyToken = (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
): void => {
	try {
		const authHeader = req.headers.authorization;
<<<<<<< HEAD
		export const verifyToken = (
			req: AuthRequest,
			res: Response,
			next: NextFunction,
		): void => {
			try {
				const authHeader = req.headers.authorization;

				// 2. ถ้าไม่มี Header หรือไม่ได้นำหน้าด้วยคำว่า "Bearer " (ช่องว่าง 1 ตัว) แปลว่าไม่ได้แนบบัตรมา
				if (!authHeader || !authHeader.startsWith("Bearer ")) {
					throw new AppError("กรุณาเข้าสู่ระบบก้อนทำรายการ (Token หายหรือไม่ถูกต้อง)", 401);
				}
				// 2. ถ้าไม่มี Header หรือไม่ได้นำหน้าด้วยคำว่า "Bearer " (ช่องว่าง 1 ตัว) แปลว่าไม่ได้แนบบัตรมา
				if (!authHeader || !authHeader.startsWith("Bearer ")) {
					throw new AppError("กรุณาเข้าสู่ระบบก้อนทำรายการ (Token หายหรือไม่ถูกต้อง)", 401);
				}

				// 3. หั่นเอาเฉพาะรหัส Token ออกมา (ตัดคำว่า "Bearer " ทิ้ง)

				console.log(authHeader);
				const token = authHeader.split(" ")[1];
				// console.log(token);

				// 4. ถ้าหยิบมาแล้วค่าว่างเปล่า
				if (!token) {
					throw new AppError("ไม่พบ Token สำหรับการยืนยันตัวตน", 401);
				}

				// 5. ตรวจสอบ "ตราประทับ" ว่าเป็นของเราจริงไหม และบัตรหมดอายุหรือยัง
				// ถ้าเกิด Error (เช่น หมดอายุ, โดนแอบแก้) ฟังก์ชัน jwt.verify จะ Throw Error อัตโนมัติ
				const decoded = jwt.verify(
					token, // รหัส Token
					config.jwt.secret, // รหัส Secret
				) as TokenPayload;
				console.log(decoded);

				// 6. ถอดรหัสผ่าน! เอาข้อมูลพนักงาน (Payload) ยัดเก็บไว้ใน `req.user`
				// เพื่อให้ด่านต่อไป (Controller) สามารถดึงไปใช้ได้เลย เช่นหาว่า request นี้ใครเป็นคนยิงมา
				req.user = decoded;

				// 7. เปิดประตูให้ Request วิ่งผ่านไปได้
				next();
			} catch (error) {
				const err = error as Error;
				// ถ้า Token หมดอายุ (TokenExpiredError) หรือ ตรวจสอบไม่ผ่าน (JsonWebTokenError)
				// ให้เด้งกลับไปหา Global Error Handler พร้อม Status 401 (Unauthorized)
				if (err.name === "TokenExpiredError") {
					next(new AppError("เซสชันของคุณหมดอายุแล้ว กรุณาเข้าสู่ระบบใหม่อีกครั้ง", 401));
				} else if (err.name === "JsonWebTokenError") {
					next(new AppError("Token สำหรับการยืนยันตัวตนไม่ถูกต้อง", 401));
				} else {
					// Error อื่นๆ ที่ไม่ได้คาดคิด
					next(error);
				}
			}
		};

		export const authorize = (...allowedRoles: string[]) => {
			return (req: AuthRequest, res: Response, next: NextFunction): void => {
				// ถ้าไม่มีข้อมูล User (แสดงว่าลืมใส่ verifyToken ก่อนหน้า) หรือ Role ของเขาไม่ได้อยู่ใน Array ที่อนุญาต
				if (!req.user || !allowedRoles.includes(req.user.role)) {
					next(new AppError("คุณไม่มีสิทธิ์เข้าถึงฟังก์ชันหรือหน้านี้ (Forbidden)", 403));
					return;
				}
				// ถ้า Role ตรงกัน ก็เปิดประตูให้ผ่าน
				next();
			};
		};

=======

		// 2. ถ้าไม่มี Header หรือไม่ได้นำหน้าด้วยคำว่า "Bearer " (ช่องว่าง 1 ตัว) แปลว่าไม่ได้แนบบัตรมา
		if (!authHeader || !authHeader.startsWith("Bearer ")) {
			throw new AppError("กรุณาเข้าสู่ระบบก้อนทำรายการ (Token หายหรือไม่ถูกต้อง)", 401);
		}

		// 3. หั่นเอาเฉพาะรหัส Token ออกมา (ตัดคำว่า "Bearer " ทิ้ง)

		console.log(authHeader);
		const token = authHeader.split(" ")[1];
		// console.log(token);

		// 4. ถ้าหยิบมาแล้วค่าว่างเปล่า
		if (!token) {
			throw new AppError("ไม่พบ Token สำหรับการยืนยันตัวตน", 401);
		}

		// 5. ตรวจสอบ "ตราประทับ" ว่าเป็นของเราจริงไหม และบัตรหมดอายุหรือยัง
		// ถ้าเกิด Error (เช่น หมดอายุ, โดนแอบแก้) ฟังก์ชัน jwt.verify จะ Throw Error อัตโนมัติ
		const decoded = jwt.verify(
			token, // รหัส Token
			config.jwt.secret, // รหัส Secret
		) as TokenPayload;
		console.log(decoded);

		// 6. ถอดรหัสผ่าน! เอาข้อมูลพนักงาน (Payload) ยัดเก็บไว้ใน `req.user`
		// เพื่อให้ด่านต่อไป (Controller) สามารถดึงไปใช้ได้เลย เช่นหาว่า request นี้ใครเป็นคนยิงมา
		req.user = decoded;

		// 7. เปิดประตูให้ Request วิ่งผ่านไปได้
		next();
	} catch (error) {
		const err = error as Error;
		// ถ้า Token หมดอายุ (TokenExpiredError) หรือ ตรวจสอบไม่ผ่าน (JsonWebTokenError)
		// ให้เด้งกลับไปหา Global Error Handler พร้อม Status 401 (Unauthorized)
		if (err.name === "TokenExpiredError") {
			next(new AppError("เซสชันของคุณหมดอายุแล้ว กรุณาเข้าสู่ระบบใหม่อีกครั้ง", 401));
		} else if (err.name === "JsonWebTokenError") {
			next(new AppError("Token สำหรับการยืนยันตัวตนไม่ถูกต้อง", 401));
		} else {
			// Error อื่นๆ ที่ไม่ได้คาดคิด
			next(error);
		}
	}
};

export const authorize = (...allowedRoles: string[]) => {
	return (req: AuthRequest, res: Response, next: NextFunction): void => {
		// ถ้าไม่มีข้อมูล User (แสดงว่าลืมใส่ verifyToken ก่อนหน้า) หรือ Role ของเขาไม่ได้อยู่ใน Array ที่อนุญาต
		if (!req.user || !allowedRoles.includes(req.user.role)) {
			next(new AppError("คุณไม่มีสิทธิ์เข้าถึงฟังก์ชันหรือหน้านี้ (Forbidden)", 403));
			return;
		}
		// ถ้า Role ตรงกัน ก็เปิดประตูให้ผ่าน
		next();
	};
};

>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c
// วิธีนำไปใช้งาน (ตัวอย่างถ้าคุณมีไฟล์ router อื่นๆ ในอนาคต): สมมติคุณมีหน้า API ให้ดึงข้อมูลค่าเช่า ซึ่งบังคับว่า "ต้อง Login ก่อนเท่านั้น" คุณก็แค่เอา verifyToken ไปวางคั่นไว้แบบนี้ครับ:

// // typescript
// import { Router } from 'express';
// import { verifyToken } from '../middlewares/auth.middleware'; // นำเข้ายาม
// import * as rentalController from './rental.controller';
// const router = Router();
// // จะเข้าถึงข้อมูลค่าเช่าได้ ต้องผ่านด่านตรวจ Token ก่อน!
// router.get('/my-rental', verifyToken, rentalController.getMyRental);
// export default router;
// // หรือถ้าอยากล็อกว่า "เฉพาะแอดมิน (สมมติ Role ID = 1) เท่านั้นที่เข้ามาดูได้"

// // typescript
// import { verifyToken, authorize } from '../middlewares/auth.middleware';
// router.get('/all-rentals', verifyToken, authorize(1), rentalController.getAllRentals);
// // เมื่อคุณเริ่มสร้าง API ระบบจัดการหอพักเพิ่มเติม (เช่น ดูห้องว่าง, เพิ่มค่าไฟ) ก็สามารถนำ 2 ตัวนี้ไปครอบ API ไว้ได้เลยครับ รับรองว่าปลอดภัย 100%! มีส่วนไหนในไฟล์ auth.middleware.ts ที่อยากให้แก้เพิ่มเติมไหมครับ?
<<<<<<< HEAD

=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c
