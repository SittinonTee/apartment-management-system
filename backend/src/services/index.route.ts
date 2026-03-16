import { Router } from "express";
import authRoute from "./auth-service/auth.route";
<<<<<<< HEAD
import billRoute from "./billing-service/bill.route";
import contractRoute from "./contract-service/contract.route";
=======
>>>>>>> origin/setup

const router = Router();

router.use("/auth", authRoute);
<<<<<<< HEAD
router.use("/contracts", contractRoute);
router.use("/bills", billRoute);
=======
>>>>>>> origin/setup

export default router;
