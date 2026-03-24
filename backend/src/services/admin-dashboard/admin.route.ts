import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import { validate } from "../../middlewares/validate.middleware";
import * as adminController from "./admin.controller";
import { addTenantSchema } from "./config/addUser.schema";

const router = Router();

router.get("/getUserData", adminController.getUserData);
router.get("/getAvailableRooms", adminController.getAvailableRooms);
router.get("/getRates", adminController.getRates);

router.post(
	"/addTenant",
	verifyToken,
	validate(addTenantSchema),
	adminController.addTenant,
);

export default router;
