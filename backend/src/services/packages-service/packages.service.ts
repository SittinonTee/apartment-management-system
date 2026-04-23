// backend/src/services/packages-service/packages.service.ts

import type { ResultSetHeader, RowDataPacket } from "mysql2/promise";
import pool from "../database";
import { sendPushNotification } from "../notification-service/notification.service";
import type { AddParcelRequest, Parcel } from "./config/type";

export const addParcel = async (data: AddParcelRequest, adminId: number) => {
	// 0. ดึงชื่อ-นามสกุล ของ Admin ที่เข้าสู่ระบบ
	const [adminUser] = await pool.query<RowDataPacket[]>(
		`SELECT firstname, lastname FROM Users WHERE user_id = ? LIMIT 1`,
		[adminId],
	);

	let receivedByAdmin = "ไม่ทราบชื่อเจ้าหน้าที่";
	if (adminUser.length > 0) {
		receivedByAdmin = `${adminUser[0].firstname} ${adminUser[0].lastname}`;
	}

	// 1. หาว่าห้องนี้คือลูกบ้าน ID อะไร โดยเช็คว่า Room ต้องเป็น OCCUPIED และ Contract ต้องเป็น ACTIVE
	const [roomUser] = await pool.query<RowDataPacket[]>(
		`SELECT u.user_id 
         FROM Room r
         INNER JOIN Contracts c ON r.room_id = c.room_id
         INNER JOIN Users u ON c.user_id = u.user_id
         WHERE r.room_number = ? 
           AND r.room_status = 'OCCUPIED' 
           AND c.status = 'ACTIVE' 
         LIMIT 1`,
		[data.room_number],
	);

	if (roomUser.length === 0) {
		throw new Error("ไม่พบห้องพักที่ระบุ, ห้องยังว่าง, หรือไม่มีสัญญาเช่าที่เปิดใช้งานอยู่");
	}

	const userId = roomUser[0].user_id;

	// 2. บันทึกพัสดุเข้า Database
	const [result] = await pool.query<ResultSetHeader>(
		`INSERT INTO Parcels (user_id, name, room_number, parcelsimage_url, status, received_by, received_at)
         VALUES (?, ?, ?, ?, 'RECEIVED', ?, ?)`,
		[
			userId,
			data.name,
			data.room_number,
			data.parcelsimage_url,
			receivedByAdmin,
			new Date(), // ใช้เวลาไทยจาก Node.js
		],
	);

	// 3. ส่ง Push Notification แจ้งเตือนลูกบ้าน
	try {
		await sendPushNotification(
			userId,
			"📦 พัสดุใหม่มาถึงแล้ว!",
			`พัสดุของคุณ (${data.name}) มาถึงแล้วที่ห้อง ${data.room_number}`,
			{ type: "parcel", id: result.insertId.toString() },
		);
	} catch (notifError) {
		console.error("⚠️ [NOTIFICATION] Failed to send push:", notifError);
		// ไม่ throw error เพื่อไม่ให้การบันทึกพัสดุหลักพัง
	}

	return { parcel_id: result.insertId, message: "รับพัสดุเข้าระบบเรียบร้อยแล้ว" };
};

export const getParcelsAdmin = async (status?: string, search?: string) => {
	// 1. อัปเดตข้อมูลใน Database อัตโนมัติ (แก้ไขสถานะเป็น PENDING จริงๆในฐานข้อมูล)
	try {
		// คำนวณวันที่ย้อนหลัง 7 วันจากเวลาปัจจุบัน (ไทย)
		const sevenDaysAgo = new Date();
		sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

		await pool.query(
			`UPDATE Parcels 
             SET status = 'PENDING' 
             WHERE status = 'RECEIVED' AND received_at <= ?`,
			[sevenDaysAgo],
		);
	} catch (_error) {
		console.error("\n DATABASE ENUM ERROR ");
	}

	let query = "SELECT * FROM Parcels WHERE 1=1";
	const params: string[] = [];

	if (status) {
		query += " AND status = ?";
		params.push(status);
	}
	if (search) {
		query += " AND (name LIKE ? OR room_number LIKE ?)";
		params.push(`%${search}%`, `%${search}%`);
	}

	query += " ORDER BY received_at DESC";

	const [rows] = await pool.query<RowDataPacket[]>(query, params);
	return rows as Parcel[];
};

export const getParcelsByUser = async (userId: number) => {
	// 1. อัปเดตข้อมูลใน Database อัตโนมัติ (แก้ไขสถานะเป็น PENDING จริงๆในฐานข้อมูล)
	try {
		const sevenDaysAgo = new Date();
		sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

		await pool.query(
			`UPDATE Parcels 
             SET status = 'PENDING' 
             WHERE status = 'RECEIVED' AND received_at <= ?`,
			[sevenDaysAgo],
		);
	} catch (_error) {
		console.error("DATABASE ENUM ERROR");
	}

	const [rows] = await pool.query<RowDataPacket[]>(
		"SELECT * FROM Parcels WHERE user_id = ? ORDER BY received_at DESC",
		[userId],
	);
	return rows as Parcel[];
};

export const markParcelAsPickedUp = async (parcelId: number) => {
	const [result] = await pool.query<ResultSetHeader>(
		`UPDATE Parcels 
         SET status = 'PICKED_UP', confirmed_at = ? 
         WHERE parcels_id = ? AND status IN ('RECEIVED', 'PENDING')`,
		[new Date(), parcelId],
	);

	if (result.affectedRows === 0) {
		throw new Error("พัสดุนี้อาจจะถูกรับไปแล้ว หรือไม่พบรายการพัสดุ");
	}

	return { message: "อัปเดตสถานะเป็น รับพัสดุแล้ว" };
};
