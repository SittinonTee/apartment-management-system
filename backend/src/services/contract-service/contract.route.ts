import { Router } from 'express';
import * as contractController from './contract.controller';
import { verifyToken } from '../../middlewares/auth.middleware';

const router = Router();

router.get('/my-contract', verifyToken, contractController.getMyContract);

export default router;
