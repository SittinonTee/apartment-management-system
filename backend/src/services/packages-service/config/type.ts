// backend/src/services/packages-service/config/type.ts

export interface Parcel {
	parcels_id: number;
	user_id: number;
	name: string;
	room_number: string;
	received_at: string | Date;
	parcelsimage_url: string;
	status: "RECEIVED" | "PICKED_UP" | "PENDING";
	confirmed_at: string | Date;
	received_by: string;
}

export interface AddParcelRequest {
	name: string;
	room_number: string;
	parcelsimage_url: string;
}
