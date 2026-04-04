import type { NextFunction, Response } from "express";
import type { AuthRequest } from "../../middlewares/auth.middleware";
import * as tenantService from "./tenant.service";

export const getMyContracts = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		// Extract user ID from the authenticated request token
		const userId = req.user?.id;

		if (!userId) {
			res.status(401).json({
				status: "error",
				message: "Unauthorized access",
			});
			return;
		}

		const result = await tenantService.getMyContracts(userId);

		res.status(200).json({
			status: "success",
			message: "Successfully retrieved contracts",
			data: result,
		});
	} catch (error) {
		// Pass error to global error handler
		next(error);
	}
};

export const getContractDetails = async (
	req: AuthRequest,
	res: Response,
	next: NextFunction,
): Promise<void> => {
	try {
		const userId = req.user?.id;
		// Cast req.params.id to string to satisfy TypeScript
		const contractId = parseInt(req.params.id as string, 10);

		if (!userId) {
			res.status(401).json({
				status: "error",
				message: "Unauthorized access",
			});
			return;
		}

		if (Number.isNaN(contractId)) {
			res.status(400).json({
				status: "error",
				message: "Invalid contract ID format",
			});
			return;
		}

		const result = await tenantService.getContractDetails(userId, contractId);

		if (!result) {
			res.status(404).json({
				status: "error",
				message: "Contract not found or you do not have permission",
			});
			return;
		}

		res.status(200).json({
			status: "success",
			message: "Successfully retrieved contract details",
			data: result,
		});
	} catch (error) {
		next(error);
	}
};
