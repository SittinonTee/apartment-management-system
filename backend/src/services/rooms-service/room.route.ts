import { Router } from "express";
import { verifyToken } from "../../middlewares/auth.middleware";
import { validate } from "../../middlewares/validate.middleware";
import * as roomController from "./room.controller";
import { addRoomSchema } from "./room.schema";

const router = Router();

// ต้องการเพิ่ม middleware ตรวจสอบว่าเป็น Admin หรือไม่ในอนาคต
router.post("/", verifyToken, validate(addRoomSchema), roomController.addRoom);
router.get("/", verifyToken, roomController.getAllRooms);
router.patch("/:id/status", verifyToken, roomController.updateRoomStatus);
router.delete("/:id", verifyToken, roomController.deleteRoom);

export default router;
