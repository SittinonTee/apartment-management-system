import { Router } from "express";
import authRoute from "./auth-service/auth.route";

const router = Router();

router.use("/auth", authRoute);

export default router;
