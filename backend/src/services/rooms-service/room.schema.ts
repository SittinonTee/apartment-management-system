import { z } from "zod";

export const addRoomSchema = z.object({
	room_number: z.string().min(1, "กรุณากรอกหมายเลขห้อง"),
	floor: z.coerce.number().int().min(1, "กรุณากรอกชั้น"),
	room_status: z.enum(["AVAILABLE", "OCCUPIED"]).default("AVAILABLE"),
});

export type V_AddRoomForm = z.infer<typeof addRoomSchema>;
