import { z } from "zod";

export const rateSchema = z.object({
	rate_room: z.string().min(1, "กรุณากรอกราคาเช่าห้องพัก"),
	rate_water: z.string().min(1, "กรุณากรอกค่าน้ำประปา"),
	rate_electric: z.string().min(1, "กรุณากรอกค่าไฟฟ้า"),
});

export type V_RateForm = z.infer<typeof rateSchema>;
