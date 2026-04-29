import pool from "../database";
import type { Bill } from "./config/type";

export const getBillsByUserId = async (userId: number): Promise<Bill[]> => {
	const query = `
        SELECT 
            b.*,
            rt.rate_room,
            rt.rate_water,
            rt.rate_electric
        FROM Bills b
        INNER JOIN Contracts c ON b.contract_id = c.contracts_id
        LEFT JOIN Rate rt ON b.rate_id = rt.rate_id
        WHERE c.user_id = ? AND c.status = 'ACTIVE'
        ORDER BY b.created_at DESC
        LIMIT 5
    `;
	const [rows] = (await pool.query(query, [userId])) as [Bill[], unknown];
	return rows;
};

export async function getAllBills(): Promise<Bill[]> {
	const query = `SELECT * FROM vw_bill_details`;
	const [rows] = (await pool.query(query)) as [Bill[], unknown];
	return rows;
}

export const approveBill = async (
	billId: number,
	adminName: string,
): Promise<boolean> => {
	const query = `
        UPDATE Bills 
        SET status = 'PAID', approved_by = ? 
        WHERE bills_id = ?
    `;
	const [result] = (await pool.query(query, [adminName, billId])) as [
		{ affectedRows: number },
		unknown,
	];
	return result.affectedRows > 0;
};

export const rejectBill = async (billId: number): Promise<boolean> => {
	const query = `
        UPDATE Bills 
        SET status = 'CANCELLED', 
            slipimage_url = NULL, 
            payment_date = NULL,
            approved_by = NULL
        WHERE bills_id = ?
    `;
	const [result] = (await pool.query(query, [billId])) as [
		{ affectedRows: number },
		unknown,
	];
	return result.affectedRows > 0;
};

interface ContractRow {
	contracts_id: number;
	rate_id: number;
	rate_room: number;
	rate_water: number;
	rate_electric: number;
}

interface BillRow {
	bills_id: number;
}

export const generateDraftBills = async (
	billMonth: string,
	contractId?: number,
): Promise<number> => {
	const [year, month] = billMonth.split("-").map(Number);
	const endOfMonth = new Date(year, month, 0, 23, 59, 59, 999);
	const endOfMonthStr = endOfMonth.toISOString().split("T")[0];

	let queryContracts = `
        SELECT c.contracts_id, c.rate_id, r.rate_room, r.rate_water, r.rate_electric
        FROM Contracts c
        LEFT JOIN Rate r ON c.rate_id = r.rate_id
        WHERE c.status = 'ACTIVE'
        AND DATE(c.start_date) <= DATE(?)
    `;
	const params: (string | number)[] = [endOfMonthStr];

	if (contractId) {
		queryContracts += ` AND c.contracts_id = ?`;
		params.push(contractId);
	}

	const [activeContracts] = (await pool.query(queryContracts, params)) as [
		ContractRow[],
		unknown,
	];

	let count = 0;
	for (const contract of activeContracts) {
		const [existing] = (await pool.query(
			"SELECT bills_id FROM Bills WHERE contract_id = ? AND bill_month = ?",
			[contract.contracts_id, billMonth],
		)) as [BillRow[], unknown];

		if (existing.length === 0) {
			const rentSnapshot = JSON.stringify({
				room: contract.rate_room || 0,
				water: contract.rate_water || 0,
				electric: contract.rate_electric || 0,
			});

			await pool.query(
				`INSERT INTO Bills (contract_id, bill_month, rate_id, rent_snapshot, status, created_at, due_date)
                 VALUES (?, ?, ?, ?, 'DRAFT', NOW(), '2026-04-30')`,
				[contract.contracts_id, billMonth, contract.rate_id, rentSnapshot],
			);
			count++;
		}
	}
	return count;
};

export const updateUnits = async (
	billId: number,
	water: number,
	electric: number,
): Promise<boolean> => {
	const query = `
        UPDATE Bills 
        SET water_unit = ?, electric_unit = ?, status = 'PENDING'
        WHERE bills_id = ? AND status = 'DRAFT'
    `;
	const [result] = (await pool.query(query, [water, electric, billId])) as [
		{ affectedRows: number },
		unknown,
	];
	return result.affectedRows > 0;
};
