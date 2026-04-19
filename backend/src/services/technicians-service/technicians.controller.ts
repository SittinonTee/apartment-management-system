import type { NextFunction, Request, Response } from "express";
import { TechniciansService } from "./technicians.service";

export const TechniciansController = {
	// ดึงรายการงานแจ้งซ่อมทั้งหมด
	async getRepairs(req: Request, res: Response, next: NextFunction) {
		try {
			const repairs = await TechniciansService.getAllRepairs();

			res.status(200).json({
				status: "success",
				data: {
					repairs,
				},
			});
		} catch (error) {
			next(error);
		}
	},

	// ช่างกดยืนยันรับงาน
	async acceptRepair(req: Request, res: Response, next: NextFunction) {
		try {
			const { repairId, technicianId, scheduledAt } = req.body;

			if (!repairId || !technicianId || !scheduledAt) {
				return res.status(400).json({
					status: "error",
					message: "ข้อมูลไม่ครบถ้วน (repairId, technicianId, scheduledAt)",
				});
			}

			const result = await TechniciansService.acceptRepair(
				Number(repairId),
				Number(technicianId),
				scheduledAt,
			);

			res.status(200).json({
				status: "success",
				message: result.message,
			});
		} catch (error) {
			next(error);
		}
	},

	// อัปเดตสถานะ
	async updateStatus(req: Request, res: Response, next: NextFunction) {
		try {
			const { repairId, status, remark } = req.body;

			if (!repairId || !status) {
				return res.status(400).json({
					status: "error",
					message: "ข้อมูลไม่ครบถ้วน (repairId, status)",
				});
			}

			const result = await TechniciansService.updateStatus(
				Number(repairId),
				status,
				remark,
			);

			res.status(200).json({
				status: "success",
				message: result.message,
			});
		} catch (error) {
			next(error);
		}
	},
};
