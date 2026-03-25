import { Router } from "express";
import adminRoute from "./admin-dashboard/admin.route";
import authRoute from "./auth-service/auth.route";
import billRoute from "./billing-service/bill.route";
import contractRoute from "./contract-service/contract.route";

const router = Router();

router.use("/auth", authRoute);
router.use("/contracts", contractRoute);
router.use("/bills", billRoute);
router.use("/admin", adminRoute);

export default router;
