import type { RowDataPacket } from "mysql2/promise";
import { pool } from "../database";

export const getMyContracts = async (userId: number) => {
	// Fetch all contracts for the specific user from the view
	const [rows] = await pool.query<RowDataPacket[]>(
		`SELECT c.*, r.room_number, r.floor, u.firstname, u.lastname 
		 FROM Contracts c
		 LEFT JOIN Room r ON c.room_id = r.room_id
		 LEFT JOIN Users u ON c.user_id = u.user_id
		 WHERE c.user_id = ? 
		 ORDER BY c.start_date DESC`,
		[userId],
	);

	return rows;
};

export const getContractDetails = async (
	userId: number,
	contractId: number,
) => {
	// Fetch specific contract details for the user
	const [rows] = await pool.query<RowDataPacket[]>(
		`SELECT c.*, r.room_number, r.floor, u.firstname, u.lastname,
		 rt.rate_water AS water_rate_per_unit, 
		 rt.rate_electric AS electric_rate_per_unit, 
		 rt.rate_room AS monthly_rent
		 FROM Contracts c
		 LEFT JOIN Room r ON c.room_id = r.room_id
		 LEFT JOIN Users u ON c.user_id = u.user_id
		 LEFT JOIN Rate rt ON c.rate_id = rt.rate_id
		 WHERE c.user_id = ? AND c.contracts_id = ?`,
		[userId, contractId],
	);

	// Return null if no contract is found to let the controller handle 404
	if (rows.length === 0) {
		return null;
	}

	// Return the first matching record
	return rows[0];
};
