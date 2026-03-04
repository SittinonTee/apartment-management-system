import { Request, Response, NextFunction } from 'express';

// สร้าง Custom Error ของระบบ
export class AppError extends Error {
  public statusCode: number;
  public status: string;
  public isOperational: boolean;

  constructor(message: string, statusCode: number) {
    super(message);
    this.statusCode = statusCode;
    this.status = `${statusCode}`.startsWith('4') ? 'fail' : 'error';    // 4xx = fail (ฝั่ง User ส่งมาผิด), 5xx = error (Server พังเอง)
    this.isOperational = true;

    Error.captureStackTrace(this, this.constructor);
  }
}


// ตรวจจับ Error ระดับ Global
export const globalErrorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  err.statusCode = err.statusCode || 500;
  err.status = err.status || 'error';

  // รันในโหมด 'development'
  if (process.env.NODE_ENV === 'development') {
    console.error('ERROR', err.message);
    res.status(err.statusCode).json({
      status: err.status,
      error: err,
      message: err.message,
      stack: err.stack,
    });
  }

  // รันในโหมด 'production'
  else {
    //มาจาก function AppError ที่เราสร้างขึ้นมา
    if (err.isOperational) {
      res.status(err.statusCode).json({
        status: err.status,
        message: err.message,
      });
    }
    // มาจาก err อะไรก็ไม่รู้ที่เราไม่ระบุ
    else {
      console.error('ERROR', err);
      res.status(500).json({
        status: 'error',
        message: 'Something went very wrong!',
      });
    }
  }
};
