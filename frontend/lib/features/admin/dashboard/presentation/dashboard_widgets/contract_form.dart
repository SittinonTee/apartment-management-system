import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/widgets/custom_text_field.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/users_info_card.dart';
import 'package:frontend/features/admin/dashboard/presentation/dashboard_widgets/custom_dropdown_menu.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/get_rate.dart';
import 'package:frontend/features/admin/dashboard/presentation/data/get_vailable_room.dart';

class ContractForm extends StatefulWidget {
  final Function(String?)? onRoomSelected;
  final Function(DateTime?)? onStartDateSelected;
  final Function(DateTime?)? onEndDateSelected;

  const ContractForm({
    super.key,
    this.onRoomSelected,
    this.onStartDateSelected,
    this.onEndDateSelected,
  });

  @override
  ContractFormState createState() => ContractFormState();
}

class ContractFormState extends State<ContractForm> {
  final _formKey = GlobalKey<FormState>();

  // ---------------- Controllers ----------------
  final _roomController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _depositController = TextEditingController();
  final _notesController = TextEditingController();
  final _rentalDurationController = TextEditingController(text: '12');
  final _ratelPriceController = TextEditingController();
  final _waterPriceController = TextEditingController();
  final _electricPriceController = TextEditingController();

  // ---------------- validate ก่อนส่งข้อมูล ----------------
  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }

  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedRoomId;
  RateTemplate? _selectedRate;
  List<RoomTemplate> _availableRooms = [];
  List<RateTemplate> _availableRates = [];

  @override
  void initState() {
    super.initState();
    _startDate = _currentDay(); // เริ่มต้นที่วันนี้
    _recalculateEndDateFromDuration(); // คำนวณวันสิ้นสุดตาม duration เริ่มต้น
    _fetchData();
  }

  // ---------------- โหลดข้อมูล ----------------
  Future<void> _fetchData() async {
    final (rooms, rates) = await (
      GetAvailableRoom().getAvailableRooms(),
      GetRate().getRates(),
    ).wait;
    if (!mounted) return;
    setState(() {
      _availableRooms = rooms;
      _availableRates = rates;
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _depositController.dispose();
    _notesController.dispose();
    _rentalDurationController.dispose();
    super.dispose();
  }

  // ---------------- ดึงข้อมูลจาก form ไปใช้ใน API ----------------
  Map<String, dynamic> getRawData() {
    return {
      'room_id': _selectedRoomId,
      'room_name': _roomController.text,
      'rate_id': _selectedRate?.id,
      'rate_room': _ratelPriceController.text,
      'rate_water': _waterPriceController.text,
      'rate_electric': _electricPriceController.text,
      // format กลับเป็น ค.ศ. รูปแบบ String (yyyy-MM-dd) ก่อนลง base
      'start_date': _startDate != null
          ? '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}'
          : null,
      'end_date': _endDate != null
          ? '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}'
          : null,
      'deposit': double.tryParse(_depositController.text),
    };
  }

  // ---------------- ดึงข้อมูลจาก form ไปใช้แสดงผล (Confirmation) ----------------
  Map<String, String> getData() {
    return {
      'เลขห้อง': _roomController.text,
      'ระยะเวลาเช่า': '${_rentalDurationController.text} เดือน',
      'วันเริ่มเข้าพัก': _formatDate(_startDate),
      'วันสิ้นสุดสัญญา': _formatDate(_endDate),
      'ค่าเช่ารายเดือน': '${_ratelPriceController.text} บาท',
      'ค่าน้ำประปา': '${_waterPriceController.text} บาท/หน่วย',
      'ค่าไฟฟ้า': '${_electricPriceController.text} บาท/หน่วย',
      'เงินประกัน': '${_depositController.text} บาท',
    };
  }

  // ---------------------------- Date & Time Logic -------------------------
  // วันที่ปัจจุบัน
  DateTime _currentDay() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // แปลงวันเป็น String (วว/ดด/ปปปป) (แสดงผลเป็น พ.ศ.)
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year + 543; // แปลงเป็น พ.ศ.
    return '$d/$m/$y';
  }

  // วันที่จาก picker > format > ให้ controller > แสดงบน textField
  void _syncDateToUI() {
    setState(() {
      _startDateController.text = _formatDate(_startDate);
      _endDateController.text = _formatDate(_endDate);
    });

    widget.onStartDateSelected?.call(_startDate);
    widget.onEndDateSelected?.call(_endDate);
  }

  // คำนวณวันสิ้นสุดจากวันเริ่มต้น or จำนวนเดือน > แสดงค่าใหม่ใน textField
  void _recalculateEndDateFromDuration() {
    // ดึงจำนวนเดือนจาก textField แปลงเป็น เลข
    final int months = int.tryParse(_rentalDurationController.text) ?? 0;
    // ใช้วันปัจจุบัน ถ้า ไม่ได้เลือกวันเริ่มเอง
    final start = _startDate ?? _currentDay();

    _endDate = DateTime(start.year, start.month + months, start.day);

    _syncDateToUI();
  }

  /// คำนวณจำนวนเดือนย้อนกลับจากวันสิ้นสุดที่เลือก
  void _recalculateDurationFromDates() {
    if (_startDate == null || _endDate == null) return;
    final start = _startDate!;
    final end = _endDate!;

    int months = (end.year - start.year) * 12 + (end.month - start.month);
    // กรณีวันของเดือนสิ้นสุดน้อยกว่าวันเริ่ม ให้ปัดลง (ไม่ครบเดือน)
    if (end.day < start.day) months--;

    setState(() {
      _rentalDurationController.text = (months > 0 ? months : 0).toString();
    });
  }

  // ถ้าได้เลือกวันเริ่มต้น ให้คำนวนวันสิ้นสุด
  void _onStartDatePicked(DateTime picked) {
    _startDate = picked;
    _recalculateEndDateFromDuration();
  }

  // ถ้าได้เลือกวันสิ้นสุด ให้คำนวนจำนวนเดือน
  void _onEndDatePicked(DateTime picked) {
    _endDate = picked;
    _recalculateDurationFromDates();
    _syncDateToUI();
  }

  // ---------------- จัดการ pick date แสดงปฎิทิน  ----------------
  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _startDate ?? _currentDay(), // เริ่มที่วันปัจจุบัน หรือ วันที่เลือก
      firstDate: _currentDay(), // กันเลือกย้อนหลัง
      lastDate: _currentDay().add(
        const Duration(days: 365),
      ), // สูงสุด 1 ปี (ไม่รู้เอาเท่าไหร่ดี)
    );
    if (picked != null) {
      _onStartDatePicked(picked); // ถ้าเลือกแล้ว ให้เอาไปคำนวนวันสิ้นสุด
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _endDate!, // ใช้ _endDate ไปเลยยังไงก็ไม่เป็น null (มันโดนคำนวนด้วย _startDate ตลอด)
      firstDate:
          _startDate ?? _currentDay(), // กันเลือกย้อนหลังวันปัจจุบัน/วันเริ่ม
      lastDate: _currentDay().add(const Duration(days: 3650)), // สูงสุด 10 ปี
    );
    if (picked != null) {
      _onEndDatePicked(picked); // ถ้าเลือกแล้ว ให้เอาไปคำนวนจำนวนเดือน
    }
  }

  // ---------------- rate + คำนวนค่าประกัน ----------------
  void _onRateSelected(RateTemplate? rate) {
    if (rate != null) {
      _selectedRate = rate;
      final int price = int.tryParse(rate.rateRoom) ?? 0;
      final int deposit = price * 2;
      // ขึ้นข้อความ
      setState(() {
        _depositController.text = deposit.toString();
        _waterPriceController.text = rate.rateWater;
        _electricPriceController.text = rate.rateElectric;
      });
    }
  }
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: null,
      shadow: true,
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: CustomDropdownMenu<String>(
                    label: 'เลขห้อง',
                    hintText: 'เลือกเลขห้อง',
                    controller: _roomController,
                    enableFilter: true,
                    requestFocusOnTap: true,
                    validator: (value) {
                      if (_selectedRoomId == null || _selectedRoomId!.isEmpty) {
                        return 'กรุณาเลือกเลขห้องพัก';
                      }
                      return null;
                    },
                    dropdownMenuEntries: _availableRooms.isEmpty
                        ? [
                            DropdownMenuEntry<String>(
                              value: '',
                              enabled: false,
                              label: 'ไม่พบห้องว่าง',
                              labelWidget: Text(
                                'ไม่พบห้องว่าง',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          ]
                        : _availableRooms.map((room) {
                            return DropdownMenuEntry<String>(
                              value: room.id,
                              label: 'ห้อง ${room.roomNumber}',
                              labelWidget: Text(
                                'ห้อง ${room.roomNumber}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            );
                          }).toList(),
                    onSelected: (roomId) {
                      setState(() {
                        _selectedRoomId = roomId;
                      });
                      widget.onRoomSelected?.call(roomId);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: CustomTextField(
                    labelText: 'ระยะเวลาเช่า',
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: _rentalDurationController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _recalculateEndDateFromDuration(),
                    suffixIcon: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text('เดือน'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    labelText: 'วันเริ่มเข้าพัก',
                    readOnly: true,
                    controller: _startDateController,
                    hintText: 'วว/ดด/ปปปป',
                    onTap: _pickStartDate,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    labelText: 'วันสิ้นสุดสัญญา',
                    readOnly: true,
                    controller: _endDateController,
                    hintText: 'วว/ดด/ปปปป',
                    onTap: _pickEndDate,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomDropdownMenu<RateTemplate>(
              label: 'ค่าเช่าห้องพักรายเดือน',
              hintText: 'เลือกเรทราคาห้องพัก',
              controller: _ratelPriceController,
              validator: (value) {
                if (_selectedRate == null) {
                  return 'กรุณาเลือกเรทราคาห้องพัก';
                }
                return null;
              },
              dropdownMenuEntries: _availableRates.map((rate) {
                return DropdownMenuEntry<RateTemplate>(
                  value: rate,
                  label: '${rate.rateRoom} บาท',
                  labelWidget: Text(
                    '${rate.rateRoom} บาท',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onSelected: (rate) {
                _onRateSelected(rate);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    readOnly: true,
                    labelText: 'ค่าน้ำประปาหน่วยละ',
                    controller: _waterPriceController,
                    keyboardType: TextInputType.number,
                    suffixIcon: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text('บาท'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomTextField(
                    readOnly: true,
                    labelText: 'ค่าไฟฟ้าหน่วยละ',
                    controller: _electricPriceController,
                    keyboardType: TextInputType.number,
                    suffixIcon: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Text('บาท'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(
              readOnly: true,
              labelText: 'เงินประกันความเสียหาย',
              controller: _depositController,
              keyboardType: TextInputType.number,
              suffixIcon: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Text('บาท'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
