const config = {
	app: {
		port: process.env.PORT || 3000,
	},
	db: {
		// main: {
		//     host: process.env.DB_HOST,
		//     port: process.env.DB_PORT,
		//     user: process.env.DB_USER,
		//     password: process.env.DB_PASSWORD,
		//     database: process.env.DB_NAME
		// },
		tidepool: {
			DATABASE_URL: process.env.DATABASE_URL,
		},
	},
	jwt: {
		secret:
			process.env.JWT_SECRET || "fallback-secret-key-please-change-in-env",
		expiresIn: process.env.JWT_EXPIRES_IN || "1d",
	},
	email: {
		user: process.env.GMAIL_USER,
		pass: process.env.GMAIL_PASS,
	},
	node_env: process.env.NODE_ENV,
};

// ตรวจสอบว่ามีตัวแปรสำคัญครบไหมก่อนเปิดเซิร์ฟเวอร์
if (!process.env.DATABASE_URL) {
	console.error(
		"FATAL ERROR: DATABASE_URL is not defined in the environment variables.",
	);
	process.exit(1);
}

if (!process.env.JWT_SECRET) {
	console.error(
		"FATAL ERROR: JWT_SECRET is not defined in the environment variables.",
	);
	process.exit(1);
}

if (!process.env.PORT) {
	console.error(
		"FATAL ERROR: PORT is not defined in the environment variables.",
	);
	process.exit(1);
}

if (!process.env.NODE_ENV) {
	console.error(
		"FATAL ERROR: NODE_ENV is not defined in the environment variables.",
	);
	process.exit(1);
}

if (!process.env.GMAIL_USER) {
	console.error(
		"FATAL ERROR: GMAIL_USER is not defined in the environment variables.",
	);
	process.exit(1);
}

if (!process.env.GMAIL_PASS) {
	console.error(
		"FATAL ERROR: GMAIL_PASS is not defined in the environment variables.",
	);
	process.exit(1);
}

export default config;
