import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import * as notificationController from "./notification.controller";

const router = Router();

router.post(
	"/register-token",
	verifyToken,
	notificationController.registerToken,
);

export default router;
