import { pool } from '../database';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { USERACCOUNT } from './config/types';
import config from '../config';








export const registerUser = async (invite_code: string, email: string, password: string) => {
    const [rows]: any = await pool.query('SELECT * FROM users WHERE invite_code = ?', [invite_code]);

    if (rows.length === 0) {
        throw new Error('ไม่มีโค้ดเชิญนี้ในระบบ หรือ โค้ดไม่ถูกต้อง');
    }

    const useraccount = rows[0] as USERACCOUNT;

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password!, salt);

    await pool.query(
        'UPDATE users SET email = ?, password = ?, status = ? WHERE invite_code = ?',
        [email, hashedPassword, 'ACTIVE', invite_code]
    );
    return {
        user: {
            email: email,
            firstname: useraccount.firstname,
            lastname: useraccount.lastname,
            role: useraccount.roles,
            status: 'ACTIVE'
        },
        token: null
    };
};





export const loginUser = async (email: string, password: string) => {
    const [rows]: any = await pool.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
        throw new Error('ไม่พบอีเมลผู้ใช้งานในระบบ');
    }

    const user = rows[0];

    if (user.status !== 'ACTIVE') {
        throw new Error('บัญชีนี้ถูกระงับหรือยังไม่เปิดใช้งาน');
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
        throw new Error('รหัสผ่านไม่ถูกต้อง');
    }

    const token = jwt.sign(
        { id: user.user_id, email: user.email, role: user.roles },
        config.jwt.secret,
        { expiresIn: config.jwt.expiresIn as any } // Token หมดอายุใน 1 วัน
    );

    return {
        user: {
            id: user.user_id,
            email: user.email,
            firstname: user.firstname,
            lastname: user.lastname,
            role: user.roles,
            status: user.status
        },
        token
    };
};

export const logoutUser = async (userId: string) => {
    await pool.query('DELETE FROM user_tokens WHERE user_id = ?', [userId]);
    return {
        user: {
            id: userId,
            email: null,
            firstname: null,
            lastname: null,
            role: null,
            status: null
        },
        token: null
    };
};