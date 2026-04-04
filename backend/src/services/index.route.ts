import { Router } from "express";
import adminRoute from "./admin-dashboard/admin.route";
import authRoute from "./auth-service/auth.route";
import billRoute from "./billing-service/bill.route";
import contractRoute from "./contract-service/contract.route";
import tenantBillingRoute from "./tenant-billing/tenant-billing.route";
import tenantRoute from "./tenant-contract/tenant.route";

const router = Router();

router.use("/auth", authRoute);
router.use("/contracts", contractRoute);
router.use("/bills", billRoute);
router.use("/admin", adminRoute);
router.use("/tenant", tenantRoute);
router.use("/tenant-billing", tenantBillingRoute);

export default router;
