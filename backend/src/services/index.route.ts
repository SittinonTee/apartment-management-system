import { Router } from 'express';
import authRoute from './auth-service/auth.route';
import adminRoute from './admin-dashboard/admin.route';

const router = Router();

router.use('/auth', authRoute);

router.use('/admin', adminRoute);

export default router;