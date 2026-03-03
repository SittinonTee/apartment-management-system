import express from 'express';
import config from './config';
import cors from 'cors';
import morgan from 'morgan';
import helmet from 'helmet';
import indexRoute from './index.route';
import { globalErrorHandler, AppError } from '../middlewares/error.middleware';

const app = express();
const port = config.app.port;

// Security Middleware ควรมี ทุก project express
app.use(helmet());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(cors());
app.use(morgan('dev'));

// ทดสอบการเชื่อมต่อ
app.get('/', (req, res) => {
    res.status(200).json({
        status: 'success',
        message: 'Successfully connected to the server'
    });
});

app.use('/api', indexRoute);


// --- โค้ดสำหรับทดสอบ Error ---
app.get('/test-error', (req, res, next) => {
    try {
        // @ts-ignore
        const a = undefinedVariable;
        res.send('รอดตาย');
    } catch (error) {
        next(error);
    }
});
// ----------------------------

// ตรวจสอบเส้นทางที่ไม่มีอยู่จริง (404 Not Found)
app.all('*splat', (req, res, next) => {
    next(new AppError(`ไม่พบเส้นทาง ${req.originalUrl} บนเซิร์ฟเวอร์นี้!`, 404));
});

//ตัวตรวจจับ Error ระดับ Global
app.use(globalErrorHandler);

app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});

export default app;
