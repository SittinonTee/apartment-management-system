import { Router } from 'express';
import * as authController from './auth.controller';
import { validate } from '../../middlewares/validate.middleware';
import { loginSchema, registerSchema } from './config/auth.schema';
import rateLimit from 'express-rate-limit';

const router = Router();

// ป้องกันการยิงรหัสผ่านรัวๆ (Brute Force)
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 นาที
    max: 5, // อนุญาตให้ยิงผิดได้สูงสุด 5 ครั้งต่อ IP ในเวลา 15 นาที
    message: { status: 'fail', message: 'คุณพยายามเข้าสู่ระบบผิดพลาดหลายครั้งเกินไป กรุณาลองใหม่ในอีก 15 นาที' }
});

router.post('/register', validate(registerSchema), authController.registerUser);

router.post('/login', loginLimiter, validate(loginSchema), authController.login);



export default router;
