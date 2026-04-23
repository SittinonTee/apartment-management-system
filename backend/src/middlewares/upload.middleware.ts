import multer from "multer";

// We use memory storage so the file is kept in RAM just long enough to upload to Firebase
const upload = multer({
	storage: multer.memoryStorage(),
	limits: {
		fileSize: 5 * 1024 * 1024, // 5MB limit
	},
	fileFilter: (req, file, cb) => {
		const allowedMimes = [
			"image/jpeg",
			"image/png",
			"image/webp",
			"image/heic",
			"image/heif",
			"application/pdf",
		];

		if (allowedMimes.includes(file.mimetype)) {
			cb(null, true);
		} else {
			cb(
				new Error(
					"ประเภทไฟล์ไม่ถูกต้อง อนุญาตเฉพาะ JPG, PNG, WEBP, HEIC และ PDF เท่านั้น",
				),
			);
		}
	},
});

export default upload;
