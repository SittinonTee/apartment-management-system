import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import * as tenantController from "./tenant.controller";

const router = Router();

// Apply verifyToken middleware to protect these routes
router.get("/my-contracts", verifyToken, tenantController.getMyContracts);
router.get(
	"/contract-details/:id",
	verifyToken,
	tenantController.getContractDetails,
);

export default router;
