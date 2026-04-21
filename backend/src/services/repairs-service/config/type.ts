export interface RepairCategory {
	category_id: number;
	name_category: string;
}

export interface RepairUser {
	repairsuser_id: number;
	user_id: number;
	category_id: number;
	head_repairs: string;
	description: string;
	preferred_time: string;
	repairsimage_url: string | null;
	status: "REPORTED" | "ASSIGNED" | "PENDING" | "COMPLETED" | "CANCELLED";
	created_at: Date;
	completed_at: Date;
}

export interface CreateRepairRequest {
	category_id: number;
	head_repairs: string;
	description: string;
	preferred_time: string;
	repairsimage_url?: string;
}

export interface UpdateRepairRequest {
	repairsuser_id: number;
	status: "REPORTED" | "ASSIGNED" | "PENDING" | "COMPLETED" | "CANCELLED";
}
