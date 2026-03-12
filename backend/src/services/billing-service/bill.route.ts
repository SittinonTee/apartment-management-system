import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import * as billController from "./bill.controller";

const router = Router();

router.get("/my-bills", verifyToken, billController.getMyBills);

export default router;
