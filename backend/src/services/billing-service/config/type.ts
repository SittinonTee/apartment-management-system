export interface Bill {
	bills_id: number; // รหัสใบแจ้งหนี้
	contract_id: number; // รหัสสัญญา
	bill_month: string; // เดือนของใบแจ้งหนี้
	rate_id: number; // รหัสอัตราค่าเช่า
	rent_snapshot: {
		// ข้อมูลอัตราค่าเช่า ณ เวลาที่สร้างใบแจ้งหนี้
		electric: number; // อัตราค่าไฟ
		room: number; // อัตราค่าห้อง
		water: number; // อัตราค่าน้ำ
	};
	water_unit_start: number; // หน่วยน้ำเริ่มต้น
	water_unit_end: number; // หน่วยน้ำสิ้นสุด
	electric_unit_start: number; // หน่วยไฟเริ่มต้น
	electric_unit_end: number; // หน่วยไฟสิ้นสุด
	status: "PENDING" | "PAID" | "CANCELED"; // สถานะใบแจ้งหนี้
	due_date: string; // วันที่ครบกำหนดชำระ
	created_at: string; // วันที่สร้างใบแจ้งหนี้
	payment_date: string | null; // วันที่ชำระเงิน
	slipimage_url: string | null; // รูปร่างใบเสร็จ
	approved_by: number | null; // รหัสผู้ตรวจสอบ
	rate_room: number; // อัตราค่าห้อง แบบที่ join
	rate_water: number; // อัตราค่าน้ำ
	rate_electric: number; // อัตราค่าไฟ
}
