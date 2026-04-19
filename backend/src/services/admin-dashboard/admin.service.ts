import type { ResultSetHeader, RowDataPacket } from "mysql2/promise";
import { uploadToFirebase } from "../../utils/firebase_upload";
import { pool } from "../database";
import type { V_AddTenantForm } from "./config/addUser.schema";
import type { USERCONTRACT } from "./config/userContractType";

export const getUserData = async () => {
	const [rows] = await pool.query<RowDataPacket[]>(`
    SELECT * FROM vw_user_contracts
  `);

	return (rows as USERCONTRACT[]).map((u: USERCONTRACT) => ({
		contract_id: u.contracts_id,
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
    SELECT room_id, room_number, floor
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
	file?: Express.Multer.File,
) => {
	if (!file) {
		throw new Error("กรุณาอัพโหลดเอกสารสัญญาฉบับกระดาษ (PDF)");
	}

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

		// 0. อัพโหลดไฟล์สัญญาไปที่ Firebase
		const contractfile_url = await uploadToFirebase(file, "contracts");

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

		await connection.query<ResultSetHeader>(
			`
      INSERT INTO Contracts (
        contract_no, identification_card, address, room_id, 
        user_id, rate_id, start_date, end_date, deposit, 
        contractfile_url, status, created_by
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'ACTIVE', ?)
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
				contractfile_url,
				adminId,
			],
		);

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

		await connection.commit();
		return { user_id: userId, contract_no };
	} catch (error) {
		await connection.rollback();
		console.error("เกิดข้อผิดพลาดในบริการเพิ่มผู้เช่า:", error);
		throw error;
	} finally {
		connection.release();
	}
};

export const terminateContract = async (
	contractId: number,
	file: Express.Multer.File | undefined,
) => {
	const connection = await pool.getConnection();
	try {
		await connection.beginTransaction();

		if (!file) throw new Error("กรุณาอัพโหลดไฟล์เอกสารการยกเลิกสัญญา");

		// 1. อัปโหลดไฟล์ไปยัง Firebase
		const cancelFileUrl = await uploadToFirebase(file, "cancel_contracts");

		// 2. ดึงข้อมูลสัญญาเพื่อหา user_id และ room_id
		const [contractInfo] = await connection.query<RowDataPacket[]>(
			"SELECT user_id, room_id FROM Contracts WHERE contracts_id = ?",
			[contractId],
		);

		if (contractInfo.length === 0) throw new Error("ไม่พบสัญญาเช่าที่ระบุ");

		const { user_id, room_id } = contractInfo[0];

		// 3. อัปเดตตาราง Contracts
		await connection.query(
			`UPDATE Contracts 
       SET status = 'TERMINATED', cancel_at = NOW(), cancelcontactfile_url = ? 
       WHERE contracts_id = ?`,
			[cancelFileUrl, contractId],
		);

		// 4. อัปเดตตาราง Room เป็นว่าง
		await connection.query(
			"UPDATE Room SET room_status = 'AVAILABLE' WHERE room_id = ?",
			[room_id],
		);

		// 5. อัปเดตตาราง Users เป็น INACTIVE (หรือจะเก็บไว้เป็นประวัติแต่เข้าใช้ระบบไม่ได้แบบ Tenant ปกติ)
		await connection.query(
			"UPDATE Users SET status = 'INACTIVE' WHERE user_id = ?",
			[user_id],
		);

		await connection.commit();
		return { status: "success" };
	} catch (error) {
		await connection.rollback();
		console.error("เกิดข้อผิดพลาดในบริการยกเลิกสัญญา:", error);
		throw error;
	} finally {
		connection.release();
	}
};
