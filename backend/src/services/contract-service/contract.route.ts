import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import * as contractController from "./contract.controller";

const router = Router();

router.get("/my-contract", verifyToken, contractController.getMyContract);

export default router;
