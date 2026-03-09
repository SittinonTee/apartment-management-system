import { Request, Response, NextFunction } from 'express';
import * as adminService from './admin.service';



export const getUserData = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    try {
        const result = await adminService.getUserData();

        res.status(200).json({
            status: 'success',
            message: 'ข้อมูลผู้ใช้ทั้งหมดสำเร็จ',
            data: result
        });
    } catch (error: any) {
        next(error);
    }
};
 