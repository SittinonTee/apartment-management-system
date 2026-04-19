import {
	getFirebaseBucket,
	initializeFirebase,
} from "./src/services/config/firebase.config";

async function setCors() {
	const admin = initializeFirebase();
	if (!admin) {
		console.error("Firebase init failed");
		process.exit(1);
	}

	const bucket = getFirebaseBucket();
	if (!bucket) {
		console.error("No bucket found");
		process.exit(1);
	}

	try {
		await bucket.setCorsConfiguration([
			{
				origin: ["*"],
				method: ["GET", "OPTIONS"],
				maxAgeSeconds: 3600,
				responseHeader: ["*"],
			},
		]);
		console.log("✅ CORS rules successfully updated for Firebase Storage!");
		process.exit(0);
	} catch (err) {
		console.error("❌ Failed to set CORS:", err);
		process.exit(1);
	}
}

setCors();
