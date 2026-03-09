import * as authController from './admin.controller';
import { Router } from 'express';

const router = Router();


router.get('/getUserData', authController.getUserData);

export default router;