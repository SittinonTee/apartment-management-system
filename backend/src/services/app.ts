import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { AppError, globalErrorHandler } from "../middlewares/error.middleware";
import config from "./config";
import indexRoute from "./index.route";
<<<<<<< HEAD
import cors from "cors";
import express from "express";
import helmet from "helmet";
import morgan from "morgan";
import { AppError, globalErrorHandler } from "../middlewares/error.middleware";
import config from "./config";
import indexRoute from "./index.route";
=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c

const app = express();
const port = config.app.port;

// Security Middleware ควรมี ทุก project express
app.use(helmet());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(cors());
app.use(morgan("dev"));
<<<<<<< HEAD
app.use(morgan("dev"));
=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c

// ทดสอบการเชื่อมต่อ
app.get("/", (req, res) => {
	res.status(200).json({
		status: "success",
		message: "Successfully connected to the server",
	});
<<<<<<< HEAD
app.get("/", (req, res) => {
	res.status(200).json({
		status: "success",
		message: "Successfully connected to the server",
	});
});

app.use("/api", indexRoute);
app.use("/api", indexRoute);
=======
});

app.use("/api", indexRoute);
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c

// --- โค้ดสำหรับทดสอบ Error ---
// app.get("/test-error", (req, res, next) => {
// 	try {
// 		// @ts-expect-error
// 		const a = undefinedVariable;
// 		res.send("รอดตาย");
// 	} catch (error) {
// 		next(error);
// 	}
// });
// ----------------------------

// ตรวจสอบเส้นทางที่ไม่มีอยู่จริง (404 Not Found)
app.all("*splat", (req, res, next) => {
	next(new AppError(`ไม่พบเส้นทาง ${req.originalUrl} บนเซิร์ฟเวอร์นี้!`, 404));
<<<<<<< HEAD
app.all("*splat", (req, res, next) => {
	next(new AppError(`ไม่พบเส้นทาง ${req.originalUrl} บนเซิร์ฟเวอร์นี้!`, 404));
=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c
});

//ตัวตรวจจับ Error ระดับ Global
app.use(globalErrorHandler);

app.listen(port, () => {
	console.log(`Server is running on port ${port}`);
<<<<<<< HEAD
	console.log(`Server is running on port ${port}`);
=======
>>>>>>> f4ea4d33d21718aa1a2642967a6bbb156512910c
});

export default app;
