import type { ResultSetHeader, RowDataPacket } from "mysql2/promise";
import { pool } from "../database";
import type { V_AddTenantForm } from "./config/addUser.schema";
import type { USERCONTRACT } from "./config/userContractType";

export const getUserData = async () => {
	const [rows] = await pool.query<RowDataPacket[]>(`
    SELECT * FROM vw_user_contracts
  `);

	return (rows as USERCONTRACT[]).map((u: USERCONTRACT) => ({
		id: u.user_id,
		firstname: u.firstname,
		lastname: u.lastname,
		phone: u.phone,
		emergency_phone: u.emergency_phone,
		email: u.email,
		role: u.roles,
		room_number: u.room_number,
		floor: u.floor,
		rate_room: u.rate_room,
		rate_water: u.rate_water,
		rate_electric: u.rate_electric,
		contract_no: u.contract_no,
		start_date: u.start_date,
		end_date: u.end_date,
		deposit: u.deposit,
		bills_no: u.bills_no,
		user_status: u.user_status,
		contract_status: u.contract_status,
	}));
};

export const getAvailableRooms = async () => {
	const [rows] = await pool.query<RowDataPacket[]>(`
    SELECT room_id, room_number, floor, room_type
    FROM Room
    WHERE room_status = 'AVAILABLE'
  `);
	return rows;
};

export const getRates = async () => {
	const [rows] = await pool.query<RowDataPacket[]>(`
    SELECT rate_id, rate_room, rate_water, rate_electric
    FROM Rate
  `);
	return rows;
};

export const addTenant = async (
	userData: V_AddTenantForm,
	adminId?: number,
) => {
	const {
		firstname,
		lastname,
		phone,
		identity_card,
		address,
		emergency_phone,
		room_id,
		rate_id,
		rate_room,
		rate_water,
		rate_electric,
		start_date,
		end_date,
		deposit,
		invite_code,
		contract_no,
		id_keycard,
	} = userData;

	const connection = await pool.getConnection();
	try {
		await connection.beginTransaction();

		// 1. Create User
		const [userResult] = await connection.query<ResultSetHeader>(
			`
      INSERT INTO Users (firstname, lastname, phone, roles, status, invite_code, id_keycard, emergency_contact)
      VALUES (?, ?, ?, 'TENANT', 'INACTIVE', ?, ?, ?)
    `,
			[
				firstname,
				lastname,
				phone,
				invite_code,
				id_keycard,
				emergency_phone || "",
			],
		);

		const userId = userResult.insertId;

		const [contractResult] = await connection.query<ResultSetHeader>(
			`
      INSERT INTO Contracts (
        contract_no, identification_card, address, room_id, 
        user_id, rate_id, start_date, end_date, deposit, 
        status, created_by
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', ?)
    `,
			[
				contract_no,
				identity_card,
				address,
				room_id,
				userId,
				rate_id,
				start_date,
				end_date,
				deposit,
				adminId,
			],
		);

		const contractId = contractResult.insertId;

		// 3. Update Room Status
		await connection.query(
			'UPDATE Room SET room_status = "OCCUPIED" WHERE room_id = ?',
			[room_id],
		);

		// 4. สร้าง rent_snapshot จาก rate ที่ส่งมา
		const rent_snapshot = JSON.stringify({
			room: rate_room,
			water: rate_water,
			electric: rate_electric,
		});
		console.log(rate_room);
		console.log(rate_water);
		console.log(rate_electric);
		console.log(rent_snapshot);

		// 5. Create Bills (เดือนแรก)
		const bill_month = new Date(start_date).toISOString().slice(0, 7); // "YYYY-MM"
		await connection.query(
			`
      INSERT INTO Bills (
        contract_id, bill_month, rate_id, rent_snapshot, water_unit, electric_unit, status
      )
      VALUES (?, ?, ?, ?, ?, ?, 'PENDING')
    `,
			[contractId, bill_month, rate_id, rent_snapshot, 0, 0],
		);

		await connection.commit();
		return { user_id: userId, contract_no };
	} catch (error) {
		await connection.rollback();
		console.error("Error in addTenant service:", error);
		throw error;
	} finally {
		connection.release();
	}
};
