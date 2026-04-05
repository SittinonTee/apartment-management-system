# Stage 1: Build
FROM node:22-alpine AS builder

# เปิดใช้งาน corepack สำหรับ pnpm
RUN corepack enable

# กำหนด working directory ภายใน container
WORKDIR /app

# คัดลอกไฟล์ที่เกี่ยวข้องกับการจัดการ package ก่อน
COPY package.json pnpm-lock.yaml ./

# ติดตั้ง dependencies ทั้งหมด รวมถึง devDependencies สำหรับการ build (tsc)
RUN pnpm install --frozen-lockfile

# คัดลอก source code ทั้งหมดไปยัง container
COPY . .

# สร้างไฟล์ production build (tsc) โดย output จะอยู่ในโฟลเดอร์ dist
RUN pnpm run build

# Stage 2: Production (ลดขนาด image โดยการคัดลอกเฉพาะสิ่งที่จำเป็นมาใช้เท่านั้น)
FROM node:22-alpine AS runner

RUN corepack enable

WORKDIR /app

# ตั้งค่า NODE_ENV
ENV NODE_ENV=production

# คัดลอกไฟล์แพ็กเกจ
COPY package.json pnpm-lock.yaml ./

# ติดตั้งเฉพาะ production dependencies (ลดขนาดของ node_modules ให้เล็กที่สุด)
RUN pnpm install --prod --frozen-lockfile

# คัดลอกไฟล์ที่ถูก build เรียบร้อยแล้ว (dist) มาจาก Stage 1
COPY --from=builder /app/dist ./dist

# โดยปกติ backend port จะตั้งค่าผ่าน ENV (Default เป็น 3000)
ENV PORT=3000
EXPOSE 3000

# รันแอปพลิเคชันจากโฟลเดอร์ที่ build เสร็จแล้ว
# จากโครงสร้างของ src: ไฟล์เริ่มต้นอยู่ที src/services/app.ts
CMD ["node", "dist/services/app.js"]
