import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class ExtendBookingScreen extends StatefulWidget {
  final String checkoutDate;
  final double dailyRate;
  final double beforeCost;

  const ExtendBookingScreen({
    Key? key,
    required this.checkoutDate,
    required this.dailyRate,
    required this.beforeCost,
  }) : super(key: key);

  @override
  _ExtendBookingScreenState createState() => _ExtendBookingScreenState();
}

class _ExtendBookingScreenState extends State<ExtendBookingScreen> {
  final DateRangePickerController _datePickerController =
  DateRangePickerController();
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _newCheckoutDate; // The calculated checkout date
  int extraDays = 0;
  late double dailyRate;
  double extraCost = 0;
  late double totalCost;

  @override
  void initState() {
    super.initState();
    totalCost = widget.beforeCost;
    dailyRate = widget.dailyRate;
    _startDate = DateTime.parse(widget.checkoutDate);
    // Set the initial selected range to start from the checkout date
    _datePickerController.selectedRange = PickerDateRange(_startDate, null);
  }

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _endDate = args.value.endDate;

        // Calculate number of days (including both start and end date)
        if (_endDate != null) {
          extraDays = _endDate!.difference(_startDate!).inDays + 1;
          extraCost = extraDays * dailyRate;
          totalCost = extraCost + widget.beforeCost;

          // Calculate new checkout date as one day after the selected end date
          _newCheckoutDate = _endDate!.add(const Duration(days: 1));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Extend Your Booking',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.amber,
        elevation: 5,
      ),
      body: SingleChildScrollView(
        // Wrap content in a SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [
              Text(
                'Select New Dates',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              Container(
                width: 350,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SfDateRangePicker(
                  controller: _datePickerController,
                  selectionMode: DateRangePickerSelectionMode.range,
                  initialSelectedRange: PickerDateRange(_startDate, null),
                  minDate: _startDate,
                  // Set minimum date to the checkout date
                  onSelectionChanged: _onSelectionChanged,
                  backgroundColor: Colors.white,
                  rangeTextStyle: const TextStyle(color: Colors.black),
                  startRangeSelectionColor: Colors.amber,
                  endRangeSelectionColor: Colors.amber,
                  rangeSelectionColor: Colors.amber.withOpacity(0.5),
                  selectionTextStyle: const TextStyle(color: Colors.white),
                  todayHighlightColor: Colors.amber,
                  enablePastDates: false,
                  // Disable dates before the checkout date
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: Colors.amber,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1,
                    weekendDays: [6, 7],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Start Date: ${DateFormat('dd/MM/yyyy').format(
                        _startDate!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  _endDate != null
                      ? Text(
                    'End Date: ${DateFormat('dd/MM/yyyy').format(_endDate!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      : const Text('End Date: Not selected'),
                  _newCheckoutDate != null
                      ? Text(
                    'New Checkout Date: ${DateFormat('dd/MM/yyyy').format(
                        _newCheckoutDate!)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                      : const Text('Checkout Date: Not calculated'),
                ],
              ),
              const SizedBox(height: 20),
              _buildCostDetails(),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed:
                  (_startDate != null && _endDate != null) ? () {
                    // logic
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_startDate != null && _endDate != null)
                        ? Colors.amber
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Extend Booking',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Extension Details',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        _buildDetailRow('Number of Extra Days', extraDays.toString()),
        _buildDetailRow('Daily Rate', 'Rs. $dailyRate'),
        _buildDetailRow('Extra Cost', 'Rs. $extraCost'),
        _buildDetailRow('Total Cost', 'Rs. $totalCost'),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
