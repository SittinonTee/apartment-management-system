import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import * as repairController from "./repair.controller";

const router = Router();

router.get("/categories", verifyToken, repairController.getCategories);
router.get("/my-repairs", verifyToken, repairController.getMyRepairs);
router.get("/all-repairs", verifyToken, repairController.getAllRepairs);
router.post("/update-repair", verifyToken, repairController.updateRepair);
router.post("/request", verifyToken, repairController.createRepair);

export default router;
