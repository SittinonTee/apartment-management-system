import { Router } from "express";
import adminRoute from "./admin-dashboard/admin.route";
import authRoute from "./auth-service/auth.route";
import billRoute from "./billing-service/bill.route";
import contractRoute from "./contract-service/contract.route";
import packagesRoute from "./packages-service/packages.route";

const router = Router();

router.use("/auth", authRoute);
router.use("/contracts", contractRoute);
router.use("/bills", billRoute);
router.use("/admin", adminRoute);
router.use("/packages", packagesRoute);

export default router;
