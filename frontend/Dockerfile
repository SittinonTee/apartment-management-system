# Stage 1: Build Flutter Web
# ใช้ Image ยอดนิยมสำหรับ Flutter จาก cirruslabs
FROM ghcr.io/cirruslabs/flutter:latest AS builder

WORKDIR /app

# คัดลอก pubspec และติดตั้ง dependencies
COPY pubspec.yaml ./
RUN flutter pub get

# คัดลอกโค้ดทั้งหมดไป build
COPY . .

# สร้างไฟล์ Web Production แบบ Release (ขนาดเล็ก ประสิทธิภาพสูง)
RUN flutter build web --release

# Stage 2: Serve Web using Nginx (ลดขนาด Image จาก ~3GB เหลือแค่ไม่กี่สิบ MB)
FROM nginx:alpine

# คัดลอกเฉพาะโฟลเดอร์เว็บที่ถูกสร้างแล้ว ไปใส่ในระบบบริการเว็บ Nginx
COPY --from=builder /app/build/web /usr/share/nginx/html

# เปิด Port 80
EXPOSE 80

# รันเซิร์ฟเวอร์ Nginx
CMD ["nginx", "-g", "daemon off;"]
