import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import upload from "../../middlewares/upload.middleware";
import * as uploadController from "./upload.controller";

const router = Router();

// Protect the route using verifyToken
router.post(
	"/",
	verifyToken,
	upload.single("file"),
	uploadController.uploadFile,
);

export default router;
