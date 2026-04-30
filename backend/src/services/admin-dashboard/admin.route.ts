import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import upload from "../../middlewares/upload.middleware";
import { validate } from "../../middlewares/validate.middleware";
import * as adminController from "./admin.controller";
import { addTenantSchema } from "./config/addUser.schema";

const router = Router();

router.get("/getUserData", adminController.getUserData);
router.get("/getTechnicians", adminController.getTechnicians);
router.get("/getAvailableRooms", adminController.getAvailableRooms);
router.get("/getRates", adminController.getRates);

router.post(
	"/addTenant",
	verifyToken,
	upload.single("contract_file"),
	validate(addTenantSchema),
	adminController.addTenant,
);

router.post(
	"/terminateContract",
	verifyToken,
	upload.single("cancel_file"),
	adminController.terminateContract,
);

export default router;
