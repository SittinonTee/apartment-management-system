import { z } from "zod";

const noEmoji = /^[^\p{Extended_Pictographic}]*$/u;
const englishOnly = /^[A-Za-z0-9]+$/;

export const loginSchema = z.object({
	email: z
		.string()
		.email("รูปแบบอีเมลไม่ถูกต้อง")
		.min(5, "อีเมลต้องมีความยาวอย่างน้อย 5 ตัวอักษร")
		.max(100, "อีเมลต้องมีความยาวไม่เกิน 100 ตัวอักษร")
		.regex(noEmoji, "อีเมลห้ามมี emoji"),
	password: z
		.string()
		.min(8, "รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร")
		.max(32, "รหัสผ่านต้องมีความยาวไม่เกิน 32 ตัวอักษร")
		.regex(noEmoji, "รหัสผ่านห้ามมี emoji")
		.regex(englishOnly, "รหัสผ่านต้องเป็นภาษาอังกฤษหรือตัวเลขเท่านั้น"),
});

export const registerSchema = z.object({
	invite_code: z
		.string()
		.min(5, "โค้ดเชิญต้องมีความยาวอย่างน้อย 5 ตัวอักษร")
		.max(100, "โค้ดเชิญต้องมีความยาวไม่เกิน 100 ตัวอักษร")
		.regex(noEmoji, "โค้ดเชิญห้ามมี emoji")
		.regex(englishOnly, "โค้ดเชิญต้องเป็นภาษาอังกฤษหรือตัวเลขเท่านั้น"),
	email: z
		.string()
		.email("รูปแบบอีเมลไม่ถูกต้อง")
		.min(5, "อีเมลต้องมีความยาวอย่างน้อย 5 ตัวอักษร")
		.max(100, "อีเมลต้องมีความยาวไม่เกิน 100 ตัวอักษร")
		.regex(noEmoji, "อีเมลห้ามมี emoji"),
	password: z
		.string()
		.min(8, "รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร")
		.max(32, "รหัสผ่านต้องมีความยาวไม่เกิน 32 ตัวอักษร")
		.regex(noEmoji, "รหัสผ่านห้ามมี emoji")
		.regex(englishOnly, "รหัสผ่านต้องเป็นภาษาอังกฤษหรือตัวเลขเท่านั้น"),
<<<<<<< HEAD
});

export const forgotPasswordSchema = z.object({
	email: z
		.string()
		.email("รูปแบบอีเมลไม่ถูกต้อง")
		.min(5, "อีเมลต้องมีความยาวอย่างน้อย 5 ตัวอักษร")
		.max(100, "อีเมลต้องมีความยาวไม่เกิน 100 ตัวอักษร")
		.regex(noEmoji, "อีเมลห้ามมี emoji"),
});

export const resetPasswordSchema = z.object({
	email: z
		.string()
		.email("รูปแบบอีเมลไม่ถูกต้อง")
		.min(5, "อีเมลต้องมีความยาวอย่างน้อย 5 ตัวอักษร")
		.max(100, "อีเมลต้องมีความยาวไม่เกิน 100 ตัวอักษร")
		.regex(noEmoji, "อีเมลห้ามมี emoji"),
	otp: z
		.string()
		.length(6, "รหัส OTP ต้องมี 6 หลัก")
		.regex(/^[0-9]+$/, "รหัส OTP ต้องเป็นตัวเลขเท่านั้น"),
	new_password: z
		.string()
		.min(8, "รหัสผ่านต้องมีความยาวอย่างน้อย 8 ตัวอักษร")
		.max(32, "รหัสผ่านต้องมีความยาวไม่เกิน 32 ตัวอักษร")
		.regex(noEmoji, "รหัสผ่านห้ามมี emoji")
		.regex(englishOnly, "รหัสผ่านต้องเป็นภาษาอังกฤษหรือตัวเลขเท่านั้น"),
=======
>>>>>>> origin/setup
});

export type V_LoginForm = z.infer<typeof loginSchema>;
export type V_RegisterForm = z.infer<typeof registerSchema>;
export type V_ForgotPasswordForm = z.infer<typeof forgotPasswordSchema>;
export type V_ResetPasswordForm = z.infer<typeof resetPasswordSchema>;
