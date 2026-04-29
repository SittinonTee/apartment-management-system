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

export const deleteRoom = async (room_id: number) => {
	await pool.query("DELETE FROM Room WHERE room_id = ?", [room_id]);
	return { room_id };
};
