import { Router } from "express";
import { TechniciansController } from "./technicians.controller";

const router = Router();

// ดึงรายการงานแจ้งซ่อมทั้งหมดสำหรับช่าง
router.get("/repairs", TechniciansController.getRepairs);

// ช่างรับงาน (กดยืนยันจากหน้าแอป)
router.post("/accept", TechniciansController.acceptRepair);

export default router;
