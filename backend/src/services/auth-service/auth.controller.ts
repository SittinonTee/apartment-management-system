import { Request, Response, NextFunction } from 'express';
import * as authService from './auth.service';
import { AppError } from '../../middlewares/error.middleware';
import { V_LoginForm, V_RegisterForm, V_ForgotPasswordForm, V_ResetPasswordForm } from './config/auth.schema';

//-----------------------------------------------------------เข้าสู่ระบบ-------------------------------------------------------------
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
//-----------------------------------------------------------ออกจากระบบ-------------------------------------------------------------
export const logout = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
        const userId = (req as any).user?.id;
        if (!userId) {
            throw new AppError('ไม่พบข้อมูลผู้ใช้งานสำหรับการออกจากระบบ', 400);
        }
        await authService.logoutUser(String(userId));

        res.status(200).json({
            status: 'success',
            message: 'ออกจากระบบสำเร็จ'
        });
    } catch (error: any) {
        next(error);
    }
};
//-----------------------------------------------------------สมัครสมาชิกบัญชี-------------------------------------------------------------
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
//-----------------------------------------------------------ลืมรหัสผ่าน-------------------------------------------------------------
export const forgotPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { email } = req.body as V_ForgotPasswordForm;
        const result = await authService.forgotPassword(email);

        res.status(200).json({
            status: 'success',
            message: result.message,
            data: { mock_otp: result.mock_otp } // ค่อยมาลบ mockup
        });
    } catch (error: any) {
        console.error("Forgot Password Error:", error);
        if (error.message === 'ไม่พบอีเมลผู้ใช้งานในระบบ') {
            next(new AppError(error.message, 404));
        } else {
            next(error);
        }
    }
};
//-----------------------------------------------------------รีเซ็ตรหัสผ่าน-------------------------------------------------------------
export const resetPassword = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
        const { email, otp, new_password } = req.body as V_ResetPasswordForm;
        const result = await authService.resetPassword(email, otp, new_password);

        res.status(200).json({
            status: 'success',
            message: result.message
        });
    } catch (error: any) {
        console.error("Reset Password Error:", error);
        if (
            error.message === 'ไม่พบอีเมลผู้ใช้งานในระบบ' ||
            error.message === 'ไม่พบคำขอรีเซ็ตรหัสผ่าน' ||
            error.message === 'รหัส OTP หมดอายุแล้ว กรุณาขอใหม่' ||
            error.message === 'รหัส OTP ไม่ถูกต้อง'
        ) {
            next(new AppError(error.message, 400));
        } else {
            next(error);
        }
    }
};