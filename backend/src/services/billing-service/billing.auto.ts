import cron from "node-cron";
import pool from "../database";
import { sendPushNotification } from "../notification-service/notification.service";

/**
 * Returns the last day of the given year and month (1-indexed month).
 */
function getLastDayOfMonth(year: number, month: number): Date {
	return new Date(year, month, 0, 23, 59, 59, 999);
}

/**
 * Returns YYYY-MM format
 */
function getYYYYMM(date: Date): string {
	const yyyy = date.getFullYear();
	const mm = String(date.getMonth() + 1).padStart(2, "0");
	return `${yyyy}-${mm}`;
}

/**
 * Returns YYYY-MM-DD format using local time (prevents -7 hours shift)
 */
function formatLocalYYYYMMDD(date: Date): string {
	const yyyy = date.getFullYear();
	const mm = String(date.getMonth() + 1).padStart(2, "0");
	const dd = String(date.getDate()).padStart(2, "0");
	return `${yyyy}-${mm}-${dd}`;
}

interface ContractRow {
	contracts_id: number;
	rate_id: number;
	start_date: string | Date;
	rate_room: number;
	rate_water: number;
	rate_electric: number;
}

interface BillRow {
	bills_id: number;
	bill_month: string;
}

async function checkAndCreateDraftBills() {
	try {
		const now = new Date();
		// Check for the current month and the previous month
		const monthsToCheck = [
			new Date(now.getFullYear(), now.getMonth() - 1, 1),
			new Date(now.getFullYear(), now.getMonth(), 1),
		];

		for (const targetDate of monthsToCheck) {
			const year = targetDate.getFullYear();
			const month = targetDate.getMonth() + 1;
			const endOfMonth = getLastDayOfMonth(year, month);
			const billMonthStr = getYYYYMM(targetDate);

			// If current time hasn't reached the end of this month yet, skip
			// We trigger draft generation ON or AFTER the exact last day of the month
			const isLastDayOrLater =
				now.getTime() >=
				new Date(year, month - 1, endOfMonth.getDate()).getTime();
			if (!isLastDayOrLater) continue;

			// Get all ACTIVE contracts where start_date is on or before the end of this month
			const queryContracts = `
				SELECT c.contracts_id, c.rate_id, c.start_date,
				       r.rate_room, r.rate_water, r.rate_electric
				FROM Contracts c
				LEFT JOIN Rate r ON c.rate_id = r.rate_id
				WHERE c.status = 'ACTIVE' 
				AND DATE(c.start_date) <= DATE(?)
			`;
			const [activeContracts] = (await pool.query(queryContracts, [
				formatLocalYYYYMMDD(endOfMonth),
			])) as [ContractRow[], unknown];

			for (const contract of activeContracts) {
				// Check if a bill already exists for this contract and month
				const _queryCheckBill = `
					SELECT bills_id FROM Bills 
					WHERE contract_id = ? AND bill_month = ?
				`;
				const [existingBills] = (await pool.query(_queryCheckBill, [
					contract.contracts_id,
					billMonthStr,
				])) as [{ bills_id: number }[], unknown];

				if (existingBills.length === 0) {
					// Create DRAFT bill with rent_snapshot
					const rentSnapshotObj = {
						room: contract.rate_room || 0,
						water: contract.rate_water || 0,
						electric: contract.rate_electric || 0,
					};
					const rentSnapshotStr = JSON.stringify(rentSnapshotObj);

					const queryInsert = `
						INSERT INTO Bills (contract_id, bill_month, rate_id, rent_snapshot, status, created_at)
						VALUES (?, ?, ?, ?, 'DRAFT', ?)
					`;
					await pool.query(queryInsert, [
						contract.contracts_id,
						billMonthStr,
						contract.rate_id,
						rentSnapshotStr,
						new Date(), // ใช้เวลาจาก Node.js ที่เป็น Asia/Bangkok
					]);
					console.log(
						`[Auto-Billing] Created DRAFT bill for contract ${contract.contracts_id} (${billMonthStr})`,
					);
				}
			}
		}
	} catch (error) {
		console.error("[Auto-Billing] Error in checkAndCreateDraftBills:", error);
	}
}

async function checkAndPublishBills() {
	try {
		const now = new Date();
		const currentMonthStr = getYYYYMM(now);

		// Find all DRAFT bills from PAST months
		// We need user_id to send notifications
		const queryDrafts = `
			SELECT b.bills_id, b.bill_month, c.user_id 
			FROM Bills b 
			INNER JOIN Contracts c ON b.contract_id = c.contracts_id
			WHERE b.status = 'DRAFT' 
			AND b.bill_month < ?
			AND b.water_unit_end IS NOT NULL 
			AND b.electric_unit_end IS NOT NULL
		`;
		const [draftBills] = (await pool.query(queryDrafts, [currentMonthStr])) as [
			(BillRow & { user_id: number })[],
			unknown,
		];

		for (const bill of draftBills) {
			const [yyyy, mm] = bill.bill_month.split("-");
			const billYear = parseInt(yyyy, 10);
			const billMonth = parseInt(mm, 10);

			const dueDateObj = getLastDayOfMonth(billYear, billMonth + 1);
			const dueDateStr = formatLocalYYYYMMDD(dueDateObj);

			const queryUpdate = `
				UPDATE Bills 
				SET status = 'PENDING', due_date = ? 
				WHERE bills_id = ?
			`;
			await pool.query(queryUpdate, [dueDateStr, bill.bills_id]);
			console.log(
				`[Auto-Billing] Published bill ${bill.bills_id} to PENDING (due: ${dueDateStr})`,
			);

			// ส่งแจ้งเตือนลูกบ้าน
			await sendPushNotification(
				bill.user_id,
				"📑 ใบแจ้งหนี้ใหม่!",
				`บิลค่าเช่าประจำเดือน ${bill.bill_month} ออกแล้ว กรุณาชำระเงินภายในวันที่ ${dueDateStr}`,
				{ type: "bill", id: bill.bills_id.toString() },
			);
		}
	} catch (error) {
		console.error("[Auto-Billing] Error in checkAndPublishBills:", error);
	}
}

async function checkOverdueBills() {
	try {
		const nowStr = formatLocalYYYYMMDD(new Date());

		// หาบิลที่กำลังจะกลายเป็น OVERDUE เพื่อเอา user_id มาแจ้งเตือน
		const queryFindOverdue = `
			SELECT b.bills_id, c.user_id, b.bill_month
			FROM Bills b
			INNER JOIN Contracts c ON b.contract_id = c.contracts_id
			WHERE b.status = 'PENDING' AND b.due_date < ?
		`;
		const [overdueBills] = (await pool.query(queryFindOverdue, [nowStr])) as [
			(BillRow & { user_id: number })[],
			unknown,
		];

		for (const bill of overdueBills) {
			const queryUpdate = `
				UPDATE Bills 
				SET status = 'OVERDUE' 
				WHERE bills_id = ?
			`;
			await pool.query(queryUpdate, [bill.bills_id]);
			console.log(`[Auto-Billing] Marked bill ${bill.bills_id} as OVERDUE.`);

			// ส่งแจ้งเตือนลูกบ้าน
			await sendPushNotification(
				bill.user_id,
				"⚠️ แจ้งเตือนค้างชำระ!",
				`บิลค่าเช่าประจำเดือน ${bill.bill_month} ของคุณเกินกำหนดชำระแล้ว กรุณาดำเนินการโดยด่วน`,
				{ type: "bill", id: bill.bills_id.toString(), status: "overdue" },
			);
		}
	} catch (error) {
		console.error("[Auto-Billing] Error in checkOverdueBills:", error);
	}
}

/**
 * Main boot-time check function
 */
export const runAutoBillingChecks = async () => {
	console.log("[Auto-Billing] Running boot-time checks...");
	await checkAndCreateDraftBills();
	await checkAndPublishBills();
	await checkOverdueBills();
	console.log("[Auto-Billing] Boot-time checks completed.");
};

/**
 * Initialize boot-time check and cron jobs
 */
export const initAutoBilling = () => {
	// 1. Run once at startup (Boot-time check)
	runAutoBillingChecks();

	// 2. Schedule cron job to run every hour at minute 0
	cron.schedule("0 * * * *", () => {
		console.log("[Auto-Billing] Running scheduled hourly check...");
		runAutoBillingChecks();
	});
};
