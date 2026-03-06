import { Router } from 'express';
import authRoute from './auth-service/auth.route';
import contractRoute from './contract-service/contract.route';

const router = Router();

router.use('/auth', authRoute);
router.use('/contracts', contractRoute);


export default router;