import { Request, Response, NextFunction } from 'express';
import * as authService from './auth.service';
import { AppError } from '../../middlewares/error.middleware';
import { V_LoginForm, V_RegisterForm } from './config/auth.schema';

export const login = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { email, password } = req.body as V_LoginForm;
        const result = await authService.loginUser(email, password);

        res.status(200).json({
            status: 'success',
            message: 'เข้าสู่ระบบสำเร็จ',
            data: result
        });
    } catch (error: any) {
        console.error("Login Error:", error);
        if (
            error.message === 'ไม่พบอีเมลผู้ใช้งานในระบบ' ||
            error.message === 'รหัสผ่านไม่ถูกต้อง' ||
            error.message === 'บัญชีนี้ถูกระงับหรือยังไม่เปิดใช้งาน'
        ) {
            next(new AppError(error.message, 401));
        } else {
            next(error);
        }
    }
};

export const registerUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { invite_code, email, password } = req.body as V_RegisterForm;
        const result = await authService.registerUser(invite_code, email, password);

        res.status(200).json({
            status: 'success',
            message: 'สมัครสมาชิกสำเร็จ',
            data: result
        });
    } catch (error: any) {
        console.error("Register Error:", error);
        if (
            error.message === 'ไม่มีโค้ดเชิญนี้ในระบบ หรือ โค้ดไม่ถูกต้อง'
        ) {
            next(new AppError(error.message, 401));
        } else {
            next(error);
        }
    }
};