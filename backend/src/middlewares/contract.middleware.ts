import { Response, NextFunction } from 'express';
import { pool } from '../services/database';
import { AuthRequest } from './auth.middleware';

/**
 * ตรวจสอบว่าสัญญาเช่ายังไม่หมดอายุ
 * (ต้องใช้หลัง verifyToken)
 */
export const checkContractExpiry = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        // 1. ต้อง login ก่อน
        if (!req.user) {
            return next(); // ถ้าไม่มี user ให้ผ่านไปก่อน เดี๋ยว route handler จัดการเอง หรือปล่อยให้ verifyToken คุม
        }

        // 2. ข้ามการเช็คสำหรับ ADMIN / TECHNICIAN
        if (req.user.role === 'ADMIN' || req.user.role === 'TECHNICIAN') {
            return next();
        }

        // 3. ดึงสัญญาที่ยัง ACTIVE
        const [rows]: any = await pool.query(
            `SELECT end_date FROM Contracts WHERE user_id = ? AND status = 'ACTIVE' LIMIT 1`,
            [req.user.id]
        );

        // 4. ตรวจสอบข้อมูลสัญญา
        let contractStatus = 'NO_CONTRACT';
        
        if (rows.length > 0) {
            const contract = rows[0];
            const today = new Date();
            const endDate = new Date(contract.end_date);

            // 5. เช็คว่าหมดอายุหรือยัง
            if (today > endDate) {
                contractStatus = 'EXPIRED';
            } else {
                contractStatus = 'ACTIVE';
            }
        }

        // แนบข้อมูลเข้าไปใน req เพื่อให้ controller นำไปใช้แจ้งเตือน user ต่อไป
        (req as any).contractStatus = contractStatus;

        // 6. ผ่านการตรวจสอบเสมอตราบใดที่ไม่มี error ระบบ (เพราะ user ต้องการแค่เอาไว้แจ้งเตือน ไม่ได้ต้องการ block)
        next();

    } catch (error: any) {
        // error จากระบบ
        console.error('Contract check failed:', error);
        next(); // ถึง error ก็ให้ทำงานต่อได้ แค่อาจจะไม่มีข้อมูลสัญญา
    }
};