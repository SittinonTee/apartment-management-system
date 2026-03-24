import { z } from "zod";

const noEmoji = /^[^\p{Extended_Pictographic}]*$/u;
const thaiEnglishOnly = /^[ก-๙A-Za-z\s]+$/;
const digitsOnly = /^[0-9]+$/;

export const addTenantSchema = z.object({
  // ข้อมูลผู้เช่า
  firstname: z.string().min(1, "กรุณากรอกชื่อจริง"),
  lastname: z.string().min(1, "กรุณากรอกนามสกุล"),
  identity_card: z.string().length(13, "เลขบัตรประชาชนต้องมี 13 หลัก"),
  phone: z.string().min(9, "เบอร์โทรศัพท์ต้องมีอย่างน้อย 9 ตัวเลข"),
  emergency_phone: z.string().optional(),
  address: z.string().min(1, "กรุณากรอกที่อยู่"),

  // ข้อมูลสัญญา
  room_id: z.string().min(1, "กรุณาเลือกเลขห้อง"),
  rate_id: z.number().int().positive(),
  start_date: z.string().min(1),
  end_date: z.string().min(1),
  deposit: z.number().positive(),
}).passthrough().refine(
  (data: any) => new Date(data.end_date) > new Date(data.start_date),
  { message: "วันสิ้นสุดสัญญาต้องหลังวันเริ่มเข้าพัก", path: ["end_date"] }
);

export type V_AddTenantForm = z.infer<typeof addTenantSchema>;