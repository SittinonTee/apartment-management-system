// backend/src/services/packages-service/packages.route.ts

import express from "express";
import { verifyToken } from "../../middlewares/auth.middleware"; // ใช้ verifyToken ตามโปรเจค
import * as parcelController from "./packages.controller";

const router = express.Router();

// ---- สำหรับ Admin ----
// GET /api/packages/admin - ดูพัสดุทั้งหมด (รับ query ?status=RECEIVED & search=room)
router.get("/admin", verifyToken, parcelController.getAdminParcels);
// POST /api/packages/admin - แอดมินคีย์พัสดุเข้า
router.post("/admin", verifyToken, parcelController.createParcel);
// PATCH /api/packages/admin/:id/pickup - เมื่อลูกบ้านมารับพัสดุให้แอดมินกดรับ
router.patch("/admin/:id/pickup", verifyToken, parcelController.pickupParcel);

// ---- สำหรับ User (ผู้เช่า) ----
// GET /api/packages/user - ดูพัสดุส่วนตัวผ่านแอปผู้เช่า
router.get("/user", verifyToken, parcelController.getUserParcels);

export default router;
