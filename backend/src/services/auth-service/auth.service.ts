import pool from '../database';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { USERACCOUNT } from './config/types';
import config from '../config';
import nodemailer from 'nodemailer';

// สร้าง Transporter สำหรับส่งอีเมล
// ถ้าใช้อีเมลของ @ethereal.email จะใช้การตั้งค่าแบบทดสอบ
// ถ้าใช้อีเมลทั่วไปจะพยายามใช้ service 'gmail'
const isEthereal = config.email.user?.endsWith('@ethereal.email');

const transporter = isEthereal
    ? nodemailer.createTransport({
        host: 'smtp.ethereal.email',
        port: 587,
        auth: {
            user: config.email.user,
            pass: config.email.pass,
        },
    })
    : nodemailer.createTransport({
        service: 'gmail',
        auth: {
            user: config.email.user,
            pass: config.email.pass,
        },
    });








//-----------------------------------------------------------สมัครสมาชิกบัญชี-------------------------------------------------------------
export const registerUser = async (invite_code: string, email: string, password: string) => {
    const [rows]: any = await pool.query('SELECT * FROM users WHERE invite_code = ?', [invite_code]);

    if (rows.length === 0) {
        throw new Error("ไม่มีโค้ดเชิญนี้ในระบบ หรือ โค้ดไม่ถูกต้อง");
    }

    const useraccount = rows[0] as USERACCOUNT;

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password!, salt);

    await pool.query(
        "UPDATE users SET email = ?, password = ?, status = ? WHERE invite_code = ?",
        [email, hashedPassword, "ACTIVE", invite_code],
    );
    return {
        user: {
            email: email,
            firstname: useraccount.firstname,
            lastname: useraccount.lastname,
            role: useraccount.roles,
            status: "ACTIVE",
        },
        token: null,
    };
};





//-----------------------------------------------------------เข้าสู่ระบบ-------------------------------------------------------------
export const loginUser = async (email: string, password: string) => {
    const [rows]: any = await pool.query("SELECT * FROM users WHERE email = ?", [
        email,
    ]);
    if (rows.length === 0) {
        throw new Error("ไม่พบอีเมลผู้ใช้งานในระบบ");
    }

    const user = rows[0];

    if (user.status !== "ACTIVE") {
        throw new Error("บัญชีนี้ถูกระงับหรือยังไม่เปิดใช้งาน");
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        throw new Error("รหัสผ่านไม่ถูกต้อง");
    }

    const token = jwt.sign(
        { id: user.user_id, email: user.email, role: user.roles },
        config.jwt.secret,
        { expiresIn: config.jwt.expiresIn as any }, // Token หมดอายุใน 1 วัน
    );

    return {
        user: {
            id: user.user_id,
            email: user.email,
            firstname: user.firstname,
            lastname: user.lastname,
            role: user.roles,
            status: user.status,
        },
        token,
    };
};
//-----------------------------------------------------------ออกจากระบบ-------------------------------------------------------------
export const logoutUser = async (userId: string) => {
    await pool.query("DELETE FROM user_tokens WHERE user_id = ?", [userId]);
    return {
        user: {
            id: userId,
            email: null,
            firstname: null,
            lastname: null,
            role: null,
            status: null,
        },
        token: null,
    };
};
//-----------------------------------------------------------ลืมรหัสผ่าน-------------------------------------------------------------
export const forgotPassword = async (email: string) => {
    const [rows]: any = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
        throw new Error('ไม่พบอีเมลผู้ใช้งานในระบบ');
    }

    const user = rows[0];

    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();

    // Hash OTP
    const salt = await bcrypt.genSalt(10);
    const hashedOtp = await bcrypt.hash(otp, salt);

    // Set expiration to 15 minutes from now
    const expires = new Date(Date.now() + 15 * 60 * 1000);

    await pool.query(
        'UPDATE users SET reset_token = ?, reset_token_expires = ? WHERE email = ?',
        [hashedOtp, expires, email]
    );

    // ปริ้นท์ OTP ออกมาทางหน้าจอ Terminal ของ Backend เพื่อให้เราก๊อปไปใช้ง่ายๆ
    console.log(`\n========================================`);
    console.log(`[DEV MODE] OTP สำหรับอีเมล ${email} คือ: ${otp}`);
    console.log(`========================================\n`);

    // ส่ง OTP ผ่านทางอีเมล
    try {
        await transporter.sendMail({
            from: `"Support System" <${config.email.user}>`, // ผู้ส่ง
            to: email, // ผู้รับ
            subject: 'รหัส OTP สำหรับรีเซ็ตรหัสผ่านของคุณ', // หัวข้ออีเมล
            html: `
                <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
                    <h2 style="color: #333; text-align: center;">รีเซ็ตรหัสผ่าน</h2>
                    <p style="font-size: 16px; color: #555;">สวัสดีครับ,</p>
                    <p style="font-size: 16px; color: #555;">เราได้รับคำขอรีเซ็ตรหัสผ่านสำหรับบัญชี <strong>${email}</strong> ของคุณ</p>
                    <p style="font-size: 16px; color: #555;">นี่คือรหัส OTP 6 หลักของคุณ (รหัสมีอายุการใช้งาน 15 นาที):</p>
                    <div style="text-align: center; margin: 30px 0;">
                        <span style="font-size: 32px; font-weight: bold; background-color: #f4f4f4; padding: 10px 20px; letter-spacing: 5px; border-radius: 5px; color: #007bff;">
                            ${otp}
                        </span>
                    </div>
                    <p style="font-size: 14px; color: #999; margin-top: 30px;">หากคุณไม่ได้เป็นผู้ขอรีเซ็ตรหัสผ่าน กรุณาเพิกเฉยต่ออีเมลฉบับนี้</p>
                </div>
            `, // เนื้อหาอีเมลรูปแบบ HTML
        });
        console.log(`✅ อีเมล OTP ถูกส่งไปยัง ${email} สำเร็จแล้ว.`);
    } catch (error) {
        console.error('❌ ไม่สามารถส่งอีเมลได้:', error);
        throw new Error('ระบบเซิร์ฟเวอร์อีเมลมีปัญหา ไม่สามารถส่ง OTP ได้ในขณะนี้');
    }

    return {
        message: 'รหัส OTP ได้ถูกส่งไปยังอีเมลของคุณแล้ว',
        mock_otp: otp // สามารถลบออกในอนาคตได้เมื่อระบบอีเมลเสถียร
    };
};
//-----------------------------------------------------------รีเซ็ตรหัสผ่าน-------------------------------------------------------------
export const resetPassword = async (email: string, otp: string, newPassword: string) => {
    const [rows]: any = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
        throw new Error('ไม่พบอีเมลผู้ใช้งานในระบบ');
    }

    const user = rows[0];

    if (!user.reset_token || !user.reset_token_expires) {
        throw new Error('ไม่พบคำขอรีเซ็ตรหัสผ่าน');
    }

    if (new Date() > new Date(user.reset_token_expires)) {
        throw new Error('รหัส OTP หมดอายุแล้ว กรุณาขอใหม่');
    }

    const isOtpValid = await bcrypt.compare(otp, user.reset_token);
    if (!isOtpValid) {
        throw new Error('รหัส OTP ไม่ถูกต้อง');
    }

    // Update password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await pool.query(
        'UPDATE users SET password = ?, reset_token = NULL, reset_token_expires = NULL WHERE email = ?',
        [hashedPassword, email]
    );

    return {
        message: 'รีเซ็ตรหัสผ่านสำเร็จ คุณสามารถเข้าสู่ระบบด้วยรหัสผ่านใหม่ได้ทันที'
    };
};