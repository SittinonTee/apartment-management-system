import { getFirebaseBucket } from "../config/firebase.config";

/**
 * Uploads a file (from multer memoryStorage) to Firebase Storage
 * @param file Express.Multer.File object
 * @param folder folder name in bucket (e.g. 'contracts', 'slips')
 * @returns public URL of the uploaded file
 */
export const uploadToFirebase = async (
	file: Express.Multer.File,
	folder: string,
): Promise<string> => {
	const bucket = getFirebaseBucket();
	if (!bucket) {
		throw new Error(
			"ระบบ Firebase ยังไม่ได้ตั้งค่า กรุณาตรวจสอบ firebase-service-account.json",
		);
	}

	const timestamp = Date.now();
	const originalName = Buffer.from(file.originalname, "latin1").toString(
		"utf-8",
	);
	const ext = originalName.split(".").pop();
	const destination = `${folder}/${timestamp}_${Math.round(Math.random() * 1000)}.${ext}`;

	const firebaseFile = bucket.file(destination);

	await firebaseFile.save(file.buffer, {
		contentType: file.mimetype,
		metadata: {
			cacheControl: "public, max-age=31536000",
		},
	});

	await firebaseFile.makePublic();
	return `https://storage.googleapis.com/${bucket.name}/${firebaseFile.name}`;
};
