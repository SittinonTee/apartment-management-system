import type { ResultSetHeader, RowDataPacket } from "mysql2/promise";
import { pool } from "../database";
import type { V_RateForm } from "./rate.schema";

export const getAllRates = async () => {
	const [rows] = await pool.query<RowDataPacket[]>(`
    SELECT * FROM Rate
  `);
	return rows;
};

export const addRate = async (rateData: V_RateForm) => {
	const { rate_room, rate_water, rate_electric } = rateData;

	const [result] = await pool.query<ResultSetHeader>(
		`
    INSERT INTO Rate (rate_room, rate_water, rate_electric)
    VALUES (?, ?, ?)
    `,
		[rate_room, rate_water, rate_electric],
	);

	return { rate_id: result.insertId, ...rateData };
};

export const updateRate = async (rate_id: number, rateData: V_RateForm) => {
	const { rate_room, rate_water, rate_electric } = rateData;

	await pool.query(
		`
    UPDATE Rate 
    SET rate_room = ?, rate_water = ?, rate_electric = ?
    WHERE rate_id = ?
    `,
		[rate_room, rate_water, rate_electric, rate_id],
	);

	return { rate_id, ...rateData };
};

export const deleteRate = async (rate_id: number) => {
	await pool.query("DELETE FROM Rate WHERE rate_id = ?", [rate_id]);
	return { rate_id };
};
