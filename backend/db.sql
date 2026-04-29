-- Database Schema Export (Synced from Actual DB)

CREATE TABLE `Bills` (
  `bills_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสบิล',
  `contract_id` int DEFAULT NULL COMMENT 'รหัสสัญญาเช่า (เพื่อรู้ว่าบิลนี้เป็นของใคร/ห้องไหน)',
  `bill_month` varchar(20) DEFAULT NULL COMMENT 'บิลประจำเดือนไหน (เช่น "2024-05")',
  `rate_id` int DEFAULT NULL COMMENT 'รหัสเรทราคาที่ใช้คำนวณบิลนี้',
  `rent_snapshot` json DEFAULT NULL COMMENT 'เรทค่าห้อง/น้ำ/ไฟ (JSON) แบบคงที่ ณ วันที่สร้างบิล ป้องกันเรทราคาในอดีตเพี้ยน',
  `water_unit` int DEFAULT NULL COMMENT 'หน่วยน้ำ (ที่แอดมินจด)',
  `electric_unit` int DEFAULT NULL COMMENT 'หน่วยไฟ (ที่แอดมินจด)',
  `status` enum('PENDING','PAID','OVERDUE','CANCELLED','DRAFT','WAITING_CONFIRM') DEFAULT NULL COMMENT 'สถานะของบิล (DRAFT, WAITING_CONFIRM, PENDING, PAID, OVERDUE, CANCELLED)',
  `due_date` date DEFAULT NULL COMMENT 'วันครบกำหนดชำระ',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาที่สร้างบิล',
  `payment_date` datetime DEFAULT NULL COMMENT 'วันเวลาที่ผู้เช่าแจ้งโอนเงิน',
  `slipimage_url` varchar(255) DEFAULT NULL COMMENT 'ลิงก์รูปสลิปโอนเงิน',
  `approved_by` varchar(100) DEFAULT NULL COMMENT 'แอดมินคนที่กดยืนยันรับเงิน/อนุมัติสลิป',
  PRIMARY KEY (`bills_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=540102;

CREATE TABLE `Contracts` (
  `contracts_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสอ้างอิงสัญญา',
  `contract_no` varchar(100) DEFAULT NULL COMMENT 'เลขที่สัญญาแบบสากล (เช่น CN-2024-001)',
  `identification_card` varchar(20) DEFAULT NULL COMMENT 'เลขบัตรประชาชนผู้เช่า',
  `address` text DEFAULT NULL COMMENT 'ที่อยู่ตามทะเบียนบ้าน',
  `room_id` varchar(50) DEFAULT NULL COMMENT 'รหัสห้องที่ทำการเช่า',
  `user_id` int DEFAULT NULL COMMENT 'รหัสลูกบ้านที่เช่า',
  `rate_id` int DEFAULT NULL COMMENT 'รหัสเรทราคาเริ่มต้นของสัญญานี้',
  `start_date` date DEFAULT NULL COMMENT 'วันที่เริ่มต้นสัญญาเช่า',
  `end_date` date DEFAULT NULL COMMENT 'วันที่สิ้นสุดสัญญาเช่า',
  `deposit` int DEFAULT NULL COMMENT 'จำนวนเงินมัดจำ / ประกัน',
  `contractfile_url` varchar(255) DEFAULT NULL COMMENT 'ลิงก์เก็บเอกสารสัญญาเช่า (PDF/รูป)',
  `status` enum('PENDING','ACTIVE','EXPIRED','TERMINATED') DEFAULT NULL COMMENT 'สถานะสัญญา (PENDING, ACTIVE, EXPIRED, TERMINATED)',
  `created_by` varchar(100) DEFAULT NULL COMMENT 'ผู้สร้างสัญญา',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาที่สร้างสัญญา',
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาที่อัปเดตสัญญา',
  `cancelcontactfile_url` varchar(255) DEFAULT NULL COMMENT 'ลิงก์เก็บเอกสารการขอยกเลิกสัญญา (ถ้ามี)',
  `cancel_at` timestamp NULL DEFAULT NULL COMMENT 'วันเวลาที่ยกเลิกสัญญา',
  PRIMARY KEY (`contracts_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=510002;

CREATE TABLE `Parcels` (
  `parcels_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสพัสดุ',
  `user_id` int DEFAULT NULL COMMENT 'รหัสลูกบ้านเจ้าของพัสดุ',
  `name` varchar(100) DEFAULT NULL COMMENT 'ชื่อหน้ากล่อง หรือบริษัทขนส่ง',
  `room_number` varchar(10) DEFAULT NULL COMMENT 'เลขห้องของเจ้าของพัสดุ',
  `received_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาที่พัสดุมาถึงนิติบุคคล',
  `parcelsimage_url` varchar(255) DEFAULT NULL COMMENT 'รูปถ่ายหน้ากล่องพัสดุ',
  `status` enum('RECEIVED','PICKED_UP','PENDING') DEFAULT NULL COMMENT 'สถานะพัสดุ (RECEIVED, PENDING, PICKED_UP)',
  `confirmed_at` timestamp NULL DEFAULT NULL COMMENT 'เวลาที่ลูกบ้านมารับพัสดุไป',
  `received_by` varchar(100) DEFAULT NULL COMMENT 'ชื่อคนรับ/ลายเซ็นคนที่มารับ',
  PRIMARY KEY (`parcels_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=330001;

CREATE TABLE `Rate` (
  `rate_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสเรทราคา',
  `rate_room` int DEFAULT NULL COMMENT 'ค่าเช่าห้องรายเดือนมาตรฐาน',
  `rate_water` int DEFAULT NULL COMMENT 'ราคาค่าน้ำ (ต่อหน่วย หรือเหมา)',
  `rate_electric` int DEFAULT NULL COMMENT 'ราคาค่าไฟ (ต่อหน่วย)',
  PRIMARY KEY (`rate_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=120002;

CREATE TABLE `Repair_categories` (
  `category_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสหมวดหมู่ปัญหา',
  `name_category` varchar(100) DEFAULT NULL COMMENT 'ชื่อหมวดหมู่ปัญหา (เช่น ประปา, ไฟฟ้า, แอร์)',
  PRIMARY KEY (`category_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=60001;

CREATE TABLE `Repairs_technicians` (
  `repairstn_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสการรับงานของช่าง',
  `repairsuser_id` int DEFAULT NULL COMMENT 'เชื่อมไปยังใบแจ้งซ่อมของลูกบ้าน',
  `technician_by` int DEFAULT NULL COMMENT 'รหัส user_id ของช่างคนที่รับงาน',
  `scheduled_at` datetime DEFAULT NULL COMMENT 'เวลานัดหมายเข้าซ่อม',
  `assigned_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาที่จ่ายงานนี้ให้ช่าง',
  `remark` varchar(255) DEFAULT NULL COMMENT 'หมายเหตุหรือบันทึกเพิ่มเติมจากช่าง',
  PRIMARY KEY (`repairstn_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=300001;

CREATE TABLE `Repairs_user` (
  `repairsuser_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสใบแจ้งซ่อม',
  `user_id` int DEFAULT NULL COMMENT 'รหัสลูกบ้านที่แจ้งซ่อม',
  `category_id` int DEFAULT NULL COMMENT 'หมวดหมู่ปัญหาที่แจ้ง',
  `head_repairs` varchar(100) DEFAULT NULL COMMENT 'หัวข้อปัญหา',
  `description` text DEFAULT NULL COMMENT 'รายละเอียดปัญหา',
  `preferred_time` varchar(100) DEFAULT NULL COMMENT 'ช่วงเวลาที่ลูกบ้านสะดวกให้ช่างเข้าซ่อม',
  `repairsimage_url` text DEFAULT NULL COMMENT 'ลิงก์รูปภาพรอยชำรุด',
  `status` enum('REPORTED','ASSIGNED','PENDING','COMPLETED','CANCELLED') DEFAULT NULL COMMENT 'สถานะการซ่อม (REPORTED, ASSIGNED, PENDING, COMPLETED, CANCELLED)',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาที่แจ้งซ่อม',
  `completed_at` datetime DEFAULT NULL COMMENT 'เวลาที่ซ่อมเสร็จสมบูรณ์',
  PRIMARY KEY (`repairsuser_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=330002;

CREATE TABLE `Room` (
  `room_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสอ้างอิงห้อง',
  `room_number` varchar(10) DEFAULT NULL COMMENT 'หมายเลขห้อง (เช่น 101, 102)',
  `floor` int DEFAULT NULL COMMENT 'ชั้นที่ห้องนั้นอยู่',
  `room_type` varchar(50) DEFAULT NULL COMMENT 'ประเภทห้อง (เช่น Studio, 1-Bedroom)',
  `room_status` enum('AVAILABLE','OCCUPIED','MAINTENANCE') DEFAULT NULL COMMENT 'สถานะห้อง (AVAILABLE, OCCUPIED, MAINTENANCE)',
  PRIMARY KEY (`room_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=270002;

CREATE TABLE `User_FCM_Tokens` (
  `fcm_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสข้อมูลแจ้งเตือน',
  `user_id` int NOT NULL COMMENT 'รหัสผู้ใช้',
  `fcm_token` varchar(255) NOT NULL COMMENT 'รหัส Token จาก Firebase ไว้สำหรับยิง Push Notification',
  `device_type` enum('ANDROID','IOS','WEB') DEFAULT 'ANDROID' COMMENT 'ประเภทของอุปกรณ์ (ANDROID, IOS, WEB)',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาสร้างโทเค็น',
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'เวลาอัปเดตโทเค็นล่าสุด',
  PRIMARY KEY (`fcm_id`) /*T![clustered_index] CLUSTERED */,
  UNIQUE KEY `fcm_token` (`fcm_token`),
  KEY `fk_1` (`user_id`),
  CONSTRAINT `fk_1` FOREIGN KEY (`user_id`) REFERENCES `Users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=30001;

CREATE TABLE `Users` (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT 'รหัสผู้ใช้ (ใช้ล็อกอิน)',
  `password` varchar(255) DEFAULT NULL COMMENT 'รหัสผ่าน (เข้ารหัสแล้ว)',
  `firstname` varchar(100) DEFAULT NULL COMMENT 'ชื่อจริง',
  `lastname` varchar(100) DEFAULT NULL COMMENT 'นามสกุล',
  `phone` varchar(20) DEFAULT NULL COMMENT 'เบอร์โทรศัพท์',
  `email` varchar(100) DEFAULT NULL COMMENT 'อีเมล',
  `roles` enum('ADMIN','TECHNICIAN','TENANT') DEFAULT 'TENANT' COMMENT 'สิทธิ์การใช้งาน (ADMIN, TECHNICIAN, TENANT)',
  `status` enum('ACTIVE','INACTIVE','BANNED') DEFAULT NULL COMMENT 'สถานะบัญชี (ACTIVE, INACTIVE, BANNED)',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP COMMENT 'เวลาสร้างบัญชี',
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'เวลาอัปเดตบัญชี',
  `id_keycard` varchar(50) DEFAULT NULL COMMENT 'รหัสบัตรคีย์การ์ดเข้าตึก',
  `emergency_contact` varchar(100) DEFAULT NULL COMMENT 'ข้อมูลติดต่อกรณีฉุกเฉิน',
  `invite_code` varchar(50) DEFAULT NULL COMMENT 'รหัสเชิญสำหรับผูกบัญชีเข้ากับสัญญาเช่าห้อง',
  `reset_token` varchar(255) DEFAULT NULL COMMENT 'รหัสสำหรับตั้งรหัสผ่านใหม่ (ลืมรหัสผ่าน)',
  `reset_token_expires` datetime DEFAULT NULL COMMENT 'เวลาหมดอายุของรหัสผ่านใหม่',
  PRIMARY KEY (`user_id`) /*T![clustered_index] CLUSTERED */
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin AUTO_INCREMENT=840002;
