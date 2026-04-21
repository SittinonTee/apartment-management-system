import type { ResultSetHeader } from "mysql2";
import pool from "../database";
import type {
	CreateRepairRequest,
	RepairCategory,
	RepairUser,
	UpdateRepairRequest,
} from "./config/type";

export const getRepairsByUserId = async (
	userId: number,
): Promise<RepairUser[]> => {
	const query = `
		SELECT * FROM vw_repairs WHERE tenant_id = ?
		ORDER BY created_at DESC
	`;
	const [rows] = (await pool.query(query, [userId])) as [RepairUser[], unknown];
	return rows;
};

export const getAllRepairs = async (): Promise<RepairUser[]> => {
	const query = `
		SELECT * from vw_repairs ORDER BY created_at DESC
	`;
	const [rows] = (await pool.query(query)) as [RepairUser[], unknown];
	return rows;
};

export const createRepairRequest = async (
	userId: number,
	data: CreateRepairRequest,
): Promise<number> => {
	const query = `
		INSERT INTO Repairs_user (
			user_id, category_id, head_repairs, description, preferred_time, repairsimage_url, status
		) VALUES (?, ?, ?, ?, ?, ?, 'REPORTED')
	`;
	const [result] = await pool.query<ResultSetHeader>(query, [
		userId,
		data.category_id,
		data.head_repairs,
		data.description,
		data.preferred_time,
		data.repairsimage_url || null,
	]);
	return result.insertId;
};

export const getCategories = async (): Promise<RepairCategory[]> => {
	const query = `SELECT * FROM Repair_categories`;
	const [rows] = (await pool.query(query)) as [RepairCategory[], unknown];
	return rows;
};

export const updateRepair = async (
	data: UpdateRepairRequest,
): Promise<number> => {
	const query = `
		UPDATE Repairs_user SET 
			status = 'CANCELLED'
		WHERE repairsuser_id = ?
	`;
	const [result] = await pool.query<ResultSetHeader>(query, [
		data.repairsuser_id,
	]);
	return result.affectedRows;
};
