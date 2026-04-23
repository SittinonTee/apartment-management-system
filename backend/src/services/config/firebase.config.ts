import fs from "node:fs";
import path from "node:path";
import * as admin from "firebase-admin";

// Defensive approach for initializing Firebase
export const initializeFirebase = () => {
	try {
		let serviceAccount: admin.ServiceAccount;

		// 1. ลองอ่านจาก Environment Variable ก่อน (สำหรับ Production บน Render)
		if (process.env.FIREBASE_SERVICE_ACCOUNT) {
			serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT.trim());
			console.log("✅ [FIREBASE] Initializing using Environment Variable.");
		} else {
			// 2. ถ้าไม่มี ให้ลองอ่านจากไฟล์ (สำหรับ Local Development)
			const keyPath = path.resolve(
				__dirname,
				"../../../firebase-service-account.json",
			);

			if (!fs.existsSync(keyPath)) {
				console.warn(
					"⚠️ [FIREBASE] 'firebase-service-account.json' not found and no Env Var. File uploads will fail.",
				);
				return null;
			}
			serviceAccount = JSON.parse(fs.readFileSync(keyPath, "utf-8"));
			console.log("✅ [FIREBASE] Initializing using local JSON file.");
		}

		if (!admin.apps.length) {
			admin.initializeApp({
				credential: admin.credential.cert(serviceAccount),
				storageBucket:
					process.env.FIREBASE_STORAGE_BUCKET || "your-project.appspot.com",
			});
			console.log("✅ [FIREBASE] Successfully initialized.");
		}

		return admin;
	} catch (error) {
		console.error("❌ [FIREBASE] Failed to initialize:", error);
		return null;
	}
};

export const getFirebaseBucket = () => {
	if (!admin.apps.length) {
		initializeFirebase();
	}
	return admin.apps.length ? admin.storage().bucket() : null;
};
