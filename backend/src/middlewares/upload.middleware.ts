import multer from "multer";

// We use memory storage so the file is kept in RAM just long enough to upload to Firebase
const upload = multer({
	storage: multer.memoryStorage(),
	limits: {
		fileSize: 5 * 1024 * 1024, // 5MB limit
	},
});

export default upload;
