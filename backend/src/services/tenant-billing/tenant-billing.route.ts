import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import { verifyBillAccess } from "../../middlewares/billing.middleware";
import * as tenantBillingController from "./tenant-billing.controller";

const router = Router();

/**
 * ดึงข้อมูลบิลของผู้เช่าเอง
 * GET /api/tenant-billing/my-bills
 */
router.get("/my-bills", verifyToken, tenantBillingController.getMyBills);

/**
 * แจ้งชำระเงิน
 * PATCH /api/tenant-billing/payment/:billId
 */
router.patch(
	"/payment/:billId",
	verifyToken,
	verifyBillAccess,
	tenantBillingController.processPayment,
);

export default router;
