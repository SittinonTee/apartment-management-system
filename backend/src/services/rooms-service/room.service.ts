import type { ResultSetHeader, RowDataPacket } from "mysql2/promise";
import { pool } from "../database";
import type { V_AddRoomForm } from "./config/room.schema";

export const addRoom = async (roomData: V_AddRoomForm) => {
	const { room_number, floor, room_status } = roomData;

	const [result] = await pool.query<ResultSetHeader>(
		`
    INSERT INTO Room (room_number, floor, room_status)
    VALUES (?, ?, ?)
    `,
		[room_number, floor, room_status],
	);

	return { room_id: result.insertId, ...roomData };
};

export const getAllRooms = async () => {
	const [rows] = await pool.query<RowDataPacket[]>(`
    SELECT * FROM Room
  `);
	return rows;
};

export const updateRoomStatus = async (room_id: number, status: string) => {
	await pool.query("UPDATE Room SET room_status = ? WHERE room_id = ?", [
		status,
		room_id,
	]);
	return { room_id, status };
};

export const updateRoom = async (
	room_id: number,
	roomData: Partial<V_AddRoomForm>,
) => {
	const fields = [];
	const values = [];

	if (roomData.room_number !== undefined) {
		fields.push("room_number = ?");
		values.push(roomData.room_number);
	}
	if (roomData.floor !== undefined) {
		fields.push("floor = ?");
		values.push(roomData.floor);
	}
	if (roomData.room_status !== undefined) {
		fields.push("room_status = ?");
		values.push(roomData.room_status);
	}

	if (fields.length === 0) return { room_id };

	values.push(room_id);
	await pool.query(
		`UPDATE Room SET ${fields.join(", ")} WHERE room_id = ?`,
		values,
	);
	return { room_id, ...roomData };
};

export const deleteRoom = async (room_id: number) => {
	// เช็คสถานะห้องก่อนว่ามีคนอยู่หรือไม่
	const [rows] = await pool.query<RowDataPacket[]>(
		"SELECT room_status FROM Room WHERE room_id = ?",
		[room_id],
	);

	if (rows.length === 0) {
		throw new Error("ไม่พบห้องที่ต้องการลบ");
	}

	if (rows[0].room_status === "OCCUPIED") {
		throw new Error("ไม่สามารถลบห้องพักนี้ได้ เนื่องจากมีผู้เช่าพักอาศัยอยู่");
	}

	await pool.query("DELETE FROM Room WHERE room_id = ?", [room_id]);
	return { room_id };
};
