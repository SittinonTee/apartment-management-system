import { Router } from "express";
import adminRoute from "./admin-dashboard/admin.route";
import authRoute from "./auth-service/auth.route";
import billRoute from "./billing-service/bill.route";
import contractRoute from "./contract-service/contract.route";
<<<<<<<<< Temporary merge branch 1
import techniciansRoute from "./technicians-service/technicians.route";
import tenantBillingRoute from "./tenant-billing/tenant-billing.route";
import tenantRoute from "./tenant-contract/tenant.route";
=========
import repairRoute from "./repairs-service/repair.route";
>>>>>>>>> Temporary merge branch 2

const router = Router();

router.use("/auth", authRoute);
router.use("/contracts", contractRoute);
router.use("/bills", billRoute);
router.use("/admin", adminRoute);
router.use("/tenant", tenantRoute);
router.use("/tenant-billing", tenantBillingRoute);
router.use("/technicians", techniciansRoute);
=========
router.use("/repairs", repairRoute);
>>>>>>>>> Temporary merge branch 2

export default router;
