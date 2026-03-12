export interface Contract {
	// Contracts table fields
	contracts_id: number; // สัญญา
	contract_no: string; // เลขที่สัญญา
	identification_card: string; // เลขที่บัตรประชาชน
	address: string; // ที่อยู่
	room_id: string; // ห้อง
	user_id: number; // ผู้เช่า
	rate_id: number; // อัตราค่าเช่า
	start_date: string; // วันที่เริ่มสัญญา
	end_date: string; // วันที่สิ้นสุดสัญญา
	deposit: string; // ประกัน
	contractfile_url: string | null; // ไฟล์สัญญา
	status: string; // สถานะสัญญา
	created_by: string; // ผู้สร้าง
	created_at: string; // วันที่สร้าง
	updated_at: string; // วันที่แก้ไข

	// Joined fields from Room
	room_number: string; // เลขที่ห้อง
	building: string; // อาคาร
	floor: number; // ชั้น
	room_type: string; // ประเภทห้อง

	// Joined fields from Rate
	rate_room: string; // อัตราค่าห้อง
	rate_water: string; // อัตราค่าน้ำ
	rate_electric: string; // อัตราค่าไฟ
}
