import type { RowDataPacket } from "mysql2/promise";
import { pool } from "../database";

export const getMyContracts = async (userId: number) => {
	// Fetch all contracts for the specific user from the view
	const [rows] = await pool.query<RowDataPacket[]>(
		`SELECT * FROM vw_contract_details WHERE user_id = ? ORDER BY start_date DESC`,
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
		`SELECT * FROM vw_contract_details WHERE user_id = ? AND contracts_id = ?`,
		[userId, contractId],
	);

	// Return null if no contract is found to let the controller handle 404
	if (rows.length === 0) {
		return null;
	}

	// Return the first matching record
	return rows[0];
};
