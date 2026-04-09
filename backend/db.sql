-- CREATE TABLE roles (
--     roles_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสบทบาท (เช่น 1=Admin, 2=User)
--     roles_name VARCHAR(100) -- ชื่อบทบาท (เช่น 'ผู้ดูแลระบบ', 'ผู้เช่า')
-- );


CREATE TABLE Room (
    room_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสอ้างอิงห้องแบบ Unique (บางทีอาจแยกจากเลขห้อง)
    room_number VARCHAR(10), -- หมายเลขห้องพัก (เช่น '101', 'A-205')
    floor INT, -- ชั้นของห้องพัก
    room_type VARCHAR(50), -- ประเภทห้อง (เช่น 'Standard', 'VIP')
    room_status ENUM('AVAILABLE', 'OCCUPIED', 'MAINTENANCE') -- สถานะปัจจุบันของห้อง
    -- available = ว่าง
    -- occupied = มีคนเช่า
    -- maintenance = ซ่อม
);

CREATE TABLE Rate (
    rate_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสเรทราคา
    rate_room VARCHAR(50), -- ราคาค่าเช่าห้องต่อเดือน
    rate_water VARCHAR(50), -- อัตราค่าน้ำ (เช่น หน่วยละ 18 บาท)
    rate_electric VARCHAR(50) -- อัตราค่าไฟ (เช่น หน่วยละ 8 บาท)
);

-- 2. สร้างตาราง Users

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสผู้ใช้งานที่ไม่ซ้ำกัน
    username VARCHAR(100), -- ชื่อบัญชีผู้ใช้สำหรับใช้เข้าระบบ (อาจใช้อีเมลแทนได้)
    password VARCHAR(255), -- รหัสผ่าน (ต้องถูก Hash เข้ารหัสก่อนบันทึก)
    firstname VARCHAR(100), -- ชื่อจริง
    lastname VARCHAR(100), -- นามสกุล
    phone VARCHAR(20), -- เบอร์โทรศัพท์ติดต่อ
    email VARCHAR(100), -- อีเมล (มักใช้สำหรับการ Login และแจ้งเตือน)
    roles ENUM('ADMIN', 'TECHNICIAN', 'TENANT') DEFAULT 'TENANT',
    -- admin = ผู้ดูแลระบบ
    -- technician = ช่าง
    -- tenant = ผู้เช่า
    status ENUM('ACTIVE', 'INACTIVE', 'BANNED'), -- สถานะของบัญชีผู้ใช้นี้
    -- active = ใช้งานได้
    -- inactive = ไม่สามารถใช้งานได้
    -- banned = ถูกแบน
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- วันและเวลาที่สร้างบัญชีนี้
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- วันและเวลาที่อัปเดตข้อมูลล่าสุด
    id_keycard VARCHAR(50), -- รหัสบัตรคีย์การ์ดเข้าหอพัก
    emergency_contact VARCHAR(100), -- ข้อมูลบุคคลติดต่อฉุกเฉิน (ชื่อและเบอร์)
    invite_code VARCHAR(50), -- โค้ดสำหรับเชิญให้มาสมัครสมาชิกเข้าหอพัก
    reset_token VARCHAR(255), -- เก็บ Token ไว้รีเซ็ตรหัสผ่าน (ที่ถูก Hash แล้ว)
    reset_token_expires DATETIME -- วันเวลาหมดอายุของ Token ลืมรหัสผ่าน
);

-- 3. สร้างตาราง Contracts
CREATE TABLE Contracts (
    contracts_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสอ้างอิงของใบสัญญาเช่า
    contract_no VARCHAR(100), -- เลขที่เอกสารสัญญา (ที่ใช้พิมพ์ออกกระดาษ)
    identification_card VARCHAR(20), -- เลขบัตรประจำตัวประชาชนของผู้เช่าตอนทำสัญญา
    address TEXT, -- ที่อยู่ตามทะเบียบบ้านของผู้เช่าตอนมาทำสัญญา
    room_id INT, -- ห้องพักที่ผูกพันตามสัญญานี้
    user_id INT, -- ผู้เช่า (เชื่อมกับตาราง users)
    rate_id INT, -- เรทราคาที่ตกลงกันไว้ (เชื่อมตาราง rate) เผื่ออนาคตเรทขึ้น สัญญานี้จะได้ยึดเรทเดิม
    start_date DATE, -- วันที่เริ่มต้นย้ายเข้าตามสัญญา
    end_date DATE, -- วันที่สิ้นสุดสัญญา
    deposit VARCHAR(50), -- จำนวนเงินมัดจำ / ล่วงหน้า
    contractfile_url VARCHAR(255), -- ลิงก์เก็บรูปภาพเอกสารสแกนใบสัญญา
    status ENUM('PENDING', 'ACTIVE', 'EXPIRED', 'TERMINATED'), -- สถานะของสัญญา
    -- pending = รออนุมัติ
    -- active = อนุมัติแล้ว
    -- expired = หมดอายุ
    -- terminated = ยกเลิก
    created_by VARCHAR(100), -- ชื่อหรือ ID ของพนักงานที่ทำการออกสัญญา
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- วันและเวลาที่สร้างสัญญา
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- วันและเวลาที่อัปเดตข้อมูลล่าสุด
);

-- 4. สร้างตาราง Bills
CREATE TABLE Bills (
    bills_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสใบแจ้งหนี้
    contract_id INT, -- อ้างอิงสัญญาเช่าเพื่อรู้ว่าชาร์จห้องไหน ใครจ่าย
    bill_month VARCHAR(20), -- รอบบิลประจำเดือน (เช่น '2024-10')
    rate_id INT, -- เรทราคาที่ใช้คำนวณบิลรอบนี้
    rent_snapshot JSON, -- ก้อนข้อมูล JSON เก็บราคาค่าเช่าตอนเดือนนั้นไว้เผื่อตรวจสอบย้อนหลัง
    water_unit_start INT, -- เลขมิเตอร์น้ำเดือนที่แล้ว
    water_unit_end INT, -- เลขมิเตอร์น้ำจดใหม่เดือนนี้
    electric_unit_start INT, -- เลขมิเตอร์ไฟเดือนที่แล้ว
    electric_unit_end INT, -- เลขมิเตอร์ไฟจดใหม่เดือนนี้
    status ENUM('PENDING', 'PAID', 'OVERDUE', 'CANCELLED'), -- สถานะใบแจ้งหนี้
    -- pending = รอชำระ
    -- paid = ชำระแล้ว
    -- overdue = ค้างชำระ
    -- cancelled = ยกเลิก
    due_date DATE, -- วันและเวลาขีดเส้นตายที่ต้องชำระเงิน
    created_at DATE, -- วันที่ออกใบแจ้งหนี้
    payment_date DATETIME, -- วันและเวลาที่ลูกบ้านแจ้งว่าโอนเงินเข้ามาแล้ว
    slipimage_url VARCHAR(255), -- ลิงก์ดูภาพสลิปโอนเงินที่ลูกบ้านแนบมา
    approved_by VARCHAR(100) -- ชื่อพนักงานที่กดยืนยันบิลใบนี้ว่ารับเงินแล้ว
);




-- -------  พัสดุ  ---------
CREATE TABLE Parcels (
    parcels_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสกล่องพัสดุรับเข้า
    user_id INT, -- รหัสลูกบ้านที่จะต้องมารับ (เจ้าของพัสดุ)
    name VARCHAR(100), -- ชื่อผู้รับพัสดุ
    room_number VARCHAR(10), -- เลขห้อง
    received_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- เวลาที่พัสดุมาถึงนิติบุคคล
    parcelsimage_url VARCHAR(255), -- รูปรวมกล่องหรือรูปชื่อหน้ากล่อง
    status ENUM('RECEIVED', 'PICKED_UP', 'PENDING'), -- สถานะพัสดุ
    -- received = รับแล้ว
    -- picked_up = รับแล้ว (ผู้เช่ามารับไปแล้ว)
    -- Pending = รอรับ/ตกค้าง
    confirmed_at TIMESTAMP, 
    -- ตราประทับเวลาอัตโนมัติเมื่อผู้เช่ามาเซ็นรับของออกไป
    received_by VARCHAR(100) -- ชื่อพนักงานนิติฯ ที่เป็นคนกดรับกล่องเข้าระบบ
);

-- 5. สร้างตาราง Repairs & Parcels
CREATE TABLE Repairs_user (
    repairsuser_id INT PRIMARY KEY AUTO_INCREMENT, -- ใบแจ้งซ่อมไอดี
    user_id INT, -- รหัสลูกบ้านที่กดแจ้งซ่อม
    category_id INT, -- หมวดหมู่ปัญหาที่แจ้ง (น้ำ ไฟ แอร์)
    head_repairs VARCHAR(100), -- หัวข้อปัญหาที่แจ้ง
    description TEXT, -- คำอธิบายอาการเสียที่ผู้เช่าพิมพ์มา
    preferred_time VARCHAR(100), -- ช่วงเวลาที่ลูกบ้านสะดวกให้ช่างเข้าห้อง
    repairsimage_url VARCHAR(255), -- ลิงก์รูปภาพของเสียที่ผู้เช่าถ่ายแนบมา
    status ENUM('REPORTED', 'ASSIGNED', 'PENDING', 'COMPLETED', 'CANCELLED'), -- สถานะใบงาน
    -- reported = แจ้งแล้ว
    -- assigned = กำลังดำเนินการ
    -- pending = รอช่าง
    -- completed = เสร็จสิ้น
    -- cancelled = ยกเลิก
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- วันและเวลาที่กดส่งใบแจ้งซ่อม
    completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP -- วันและเวลาที่ช่างกดซ่อมเสร็จปิดงาน
);

-- แจ้งซ่อม Technicians
CREATE TABLE Repairs_technicians (
    repairstn_id INT PRIMARY KEY AUTO_INCREMENT, -- ไอดีใบงานฝั่งช่าง
    repairsuser_id INT, -- อ้างอิงไอดีใบแจ้งซ่อมที่ลูกบ้านส่งมา (ลิงก์หากัน)
    technician_by INT, -- รหัสเข้าสู่ระบบ (user_id) ของช่างซ่อมบำรุงที่รับผิดชอบงานนี้
    scheduled_at DATETIME, -- วันที่ช่างสะดวกเข้ารับงาน
    estimated_end_time DATETIME, -- เวลาที่คาดว่าจะซ่อมเสร็จเพื่อป้องกันรับงานชนกัน
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- วันและเวลาที่แอดมินหรือระบบแจกงานนี้ให้ช่าง
    remark VARCHAR(255) -- หมายเหตุเพิ่มเติมจากช่าง (เช่น เปลี่ยนอะไหล่อะไรไปบ้าง)
);

CREATE TABLE Repair_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT, -- รหัสหมวดหมู่การแจ้งซ่อม
    name_category VARCHAR(100) -- ชื่อหมวดหมู่ (เช่น 'ประปา', 'แอร์', 'ไฟฟ้า')
);

