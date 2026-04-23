import type { FieldPacket, RowDataPacket } from "mysql2/promise";
import { getFirebaseMessaging } from "../config/firebase.config";
import pool from "../database";

interface FCMTokenRow extends RowDataPacket {
	fcm_token: string;
}

export const registerFCMToken = async (
	userId: number,
	token: string,
	deviceType: "ANDROID" | "IOS" | "WEB",
) => {
	// ใช้ INSERT ... ON DUPLICATE KEY UPDATE เพื่อความสะดวก
	await pool.query(
		`INSERT INTO User_FCM_Tokens (user_id, fcm_token, device_type) 
         VALUES (?, ?, ?) 
         ON DUPLICATE KEY UPDATE device_type = ?, updated_at = CURRENT_TIMESTAMP`,
		[userId, token, deviceType, deviceType],
	);
};

export const deleteFCMToken = async (token: string) => {
	await pool.query("DELETE FROM User_FCM_Tokens WHERE fcm_token = ?", [token]);
};

export const sendPushNotification = async (
	userId: number,
	title: string,
	body: string,
	data?: Record<string, string>,
) => {
	const messaging = getFirebaseMessaging();
	if (!messaging) {
		console.warn(
			"⚠️ [NOTIFICATION] Firebase Messaging not initialized. Skipping push.",
		);
		return;
	}

	// ดึง Token ทั้งหมดของ User นี้ (อาจมีหลายเครื่อง)
	const [tokens] = (await pool.query(
		"SELECT fcm_token FROM User_FCM_Tokens WHERE user_id = ?",
		[userId],
	)) as [FCMTokenRow[], FieldPacket[]];

	if (tokens.length === 0) {
		console.log(`ℹ️ [NOTIFICATION] No FCM tokens found for user ${userId}`);
		return;
	}

	const messagePayloads = tokens.map((t) => ({
		token: t.fcm_token,
		notification: {
			title,
			body,
		},
		data: data || {},
	}));

	// ส่งทีละใบ หรือใช้ sendEach (แนะนำ sendEach สำหรับ Firebase Admin SDK v10+)
	try {
		const response = await messaging.sendEach(messagePayloads);
		console.log(
			`✅ [NOTIFICATION] Successfully sent ${response.successCount} messages.`,
		);

		// ถ้ามีใบไหนส่งไม่สำเร็จเพราะ Token หมดอายุ ให้ลบทิ้ง
		response.responses.forEach((resp, idx) => {
			if (!resp.success && resp.error) {
				const errorCode = resp.error.code;
				if (
					errorCode === "messaging/registration-token-not-registered" ||
					errorCode === "messaging/invalid-registration-token"
				) {
					console.log(
						`🗑️ [NOTIFICATION] Removing invalid token: ${tokens[idx].fcm_token}`,
					);
					deleteFCMToken(tokens[idx].fcm_token);
				}
			}
		});
	} catch (error) {
		console.error("❌ [NOTIFICATION] Error sending push notification:", error);
	}
};
