import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'add_event_screen.dart'; // Import the new file

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EZ Fit',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalendarScreen(),
      routes: {
        '/add_event': (context) {
          final selectedDate =
              ModalRoute.of(context)?.settings.arguments as DateTime?;
          return AddEventScreen(selectedDate: selectedDate);
        },
      },
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentDate = DateTime.now();

  void _goToPreviousDay() {
    setState(() {
      _currentDate = _currentDate.subtract(const Duration(days: 1));
    });
  }

  void _goToNextDay() {
    setState(() {
      _currentDate = _currentDate.add(const Duration(days: 1));
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _currentDate = date;
    });
  }

  void _navigateToAddEvent() {
    Navigator.pushNamed(context, '/add_event', arguments: _currentDate);
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstDayOfWeek =
        firstDayOfMonth.weekday; // 1 for Monday, 7 for Sunday

    final List<Widget> calendarDays = [];

    // Add empty boxes for the days before the first day of the month
    for (int i = 0; i < (firstDayOfWeek == 7 ? 0 : firstDayOfWeek); i++) {
      calendarDays.add(const SizedBox(width: 40.0, height: 40.0));
    }

    // Build the days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final currentDateInMonth = DateTime(
        _currentDate.year,
        _currentDate.month,
        day,
      );
      final isToday =
          currentDateInMonth.year == DateTime.now().year &&
          currentDateInMonth.month == DateTime.now().month &&
          currentDateInMonth.day == DateTime.now().day;
      final isSelected =
          currentDateInMonth.year == _currentDate.year &&
          currentDateInMonth.month == _currentDate.month &&
          currentDateInMonth.day == _currentDate.day;

      calendarDays.add(
        GestureDetector(
          onTap: () => _selectDate(currentDateInMonth),
          child: Container(
            width: 40.0,
            height: 40.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Colors.grey : null,
              border: isToday
                  ? Border.all(color: Colors.black, width: 2.0)
                  : null,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      children: calendarDays,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'EEEE, MMMM d, y',
    ).format(_currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EZ Fitness'),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 8.0,
              color: Colors.blue,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _goToPreviousDay,
                ),
                Expanded(
                  child: Text(
                    formattedDate,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _goToNextDay,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              color: Colors.grey,
              margin: EdgeInsets.zero,
              child: InkWell(
                onTap: _navigateToAddEvent,
                child: const SizedBox(
                  height: 60.0,
                  child: Center(
                    child: Icon(Icons.add, size: 30.0, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Placeholder for scheduled items
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Scheduled Items will go here (scrollable list)'),
          ),

          const SizedBox(height: 20),
          _buildCalendar(), // Call the calendar building widget
        ],
      ),
    );
  }
}
