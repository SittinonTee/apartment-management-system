import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import { validate } from "../../middlewares/validate.middleware";
import * as rateController from "./rate.controller";
import { rateSchema } from "./rate.schema";

const router = Router();

router.get("/", verifyToken, rateController.getAllRates);
router.post("/", verifyToken, validate(rateSchema), rateController.addRate);
router.patch(
	"/:id",
	verifyToken,
	validate(rateSchema),
	rateController.updateRate,
);
router.delete("/:id", verifyToken, rateController.deleteRate);

export default router;
