import fs from "node:fs";
import path from "node:path";
import * as admin from "firebase-admin";

// Defensive approach for initializing Firebase
export const initializeFirebase = () => {
	try {
		// Assume file is in the backend root
		const keyPath = path.resolve(
			__dirname,
			"../../../firebase-service-account.json",
		);

		if (!fs.existsSync(keyPath)) {
			console.warn(
				"⚠️ [FIREBASE] 'firebase-service-account.json' not found. File uploads will fail.",
			);
			return null;
		}

		const serviceAccount = JSON.parse(fs.readFileSync(keyPath, "utf-8"));

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
