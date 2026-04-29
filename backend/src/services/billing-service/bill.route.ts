import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import * as billController from "./bill.controller";

const router = Router();

router.get("/my-bills", verifyToken, billController.getMyBills);
router.get("/all-bills", verifyToken, billController.getAllBills);
router.patch("/approve/:billId", verifyToken, billController.approveBill);
router.patch("/reject/:billId", verifyToken, billController.rejectBill);
router.patch("/update-units/:billId", verifyToken, billController.updateUnits);
router.post("/debug/generate-drafts", billController.generateDebugDraftBills);

export default router;
