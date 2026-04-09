import type { RowDataPacket } from "mysql2/promise";

export interface BILL_DETAILS extends RowDataPacket {
	bills_id: number;
	contract_id: number;
	user_id: number;
	room_id: number;
	room_number: string;
	bill_month: string;
	status: "PENDING" | "PAID" | "OVERDUE" | "CANCELLED";
	due_date: string | null;
	created_at: string;
	payment_date: string | null;
	slipimage_url: string | null;
	approved_by: string | null;
	rate_room: number;
	rate_water: number;
	rate_electric: number;
	water_used: number;
	electric_used: number;
	water_total: number;
	electric_total: number;
	room_total: number;
	grand_total: number;
}
