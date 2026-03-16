import { Router } from "express";
import authRoute from "./auth-service/auth.route";
import billRoute from "./billing-service/bill.route";
import contractRoute from "./contract-service/contract.route";

const router = Router();

router.use("/auth", authRoute);
router.use("/contracts", contractRoute);
router.use("/bills", billRoute);

export default router;
<<<<<<< HEAD

=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c
