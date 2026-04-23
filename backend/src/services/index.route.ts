import { Router } from "express";
import adminRoute from "./admin-dashboard/admin.route";
import authRoute from "./auth-service/auth.route";
import billRoute from "./billing-service/bill.route";
import contractRoute from "./contract-service/contract.route";
import notificationRoute from "./notification-service/notification.route";
import packagesRoute from "./packages-service/packages.route";
import rateRoute from "./rates-service/rate.route";
import repairRoute from "./repairs-service/repair.route";
import roomRoute from "./rooms-service/room.route";
import techniciansRoute from "./technicians-service/technicians.route";
import tenantBillingRoute from "./tenant-billing/tenant-billing.route";
import tenantRoute from "./tenant-contract/tenant.route";
import uploadRoute from "./upload-service/upload.route";

const router = Router();

router.use("/auth", authRoute);
router.use("/contracts", contractRoute);
router.use("/bills", billRoute);
router.use("/admin", adminRoute);
router.use("/rooms", roomRoute);
router.use("/rates", rateRoute);
router.use("/tenant", tenantRoute);
router.use("/tenant-billing", tenantBillingRoute);
router.use("/technicians", techniciansRoute);
router.use("/repairs", repairRoute);
router.use("/upload", uploadRoute);
router.use("/packages", packagesRoute);
router.use("/notifications", notificationRoute);

export default router;
