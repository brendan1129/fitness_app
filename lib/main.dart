import 'package:fitness_app/event_storage.dart';
import 'package:fitness_app/model/fitness_event.dart';

import 'review_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';
import 'add_event_screen.dart'; // Add New Event Form Page

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter binding is initialized

  // Lock rotation to portrait mode
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
      title: 'BZ Fitness',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CalendarScreen(),
      routes: {
        '/add_event': (context) {
          final selectedDate =
              ModalRoute.of(context)?.settings.arguments as DateTime?;
          return AddEventScreen(selectedDate: selectedDate);
        },
        '/review_event': (context) {
          final FitnessEvent eventDetails =
              ModalRoute.of(context)!.settings.arguments as FitnessEvent;
          return ReviewEventScreen(event: eventDetails);
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
  // List of plan options for the dropdown.
  final List<String> _options = ['All'];

  final EventStorage _eventStorage = EventStorage();

  String? _selectedOption;

  DateTime _currentDate = DateTime.now();
  late Future<Map<DateTime, List<FitnessEvent>>>
  _eventsFuture; // Use a Future to hold the events

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents(); // Initialize in initState
  }

  /// Async future to pull [FitnessEvent] list from prefs
  Future<Map<DateTime, List<FitnessEvent>>> _loadEvents() async {
    // Get list of Workout/Meal Strings saved to myEventSummariesKey

    final List<FitnessEvent> allEvents = await _eventStorage.getAllEvents();

    // 2. Map to store Event summaries, grouped by their normalized date
    final Map<DateTime, List<FitnessEvent>> eventsByDate = {};
    // 3. Iterate through each Event object
    for (final event in allEvents) {
      // Normalize the date to year, month, day to group all events that occurred on the same calendar day.
      // This removes time components (hours, minutes, seconds)
      final normalizedDate = DateTime(
        event.eventDate.year,
        event.eventDate.month,
        event.eventDate.day,
      );

      // Get the summary string for the entire Event object.
      // The Event class's getSummary() method aggregates summaries from its EventItems.
      // final eventSummary = event.getSummary();

      // Ensure a list exists for this specific date in the map.
      // If the date is not yet a key, create a new empty list for it.
      if (!eventsByDate.containsKey(normalizedDate)) {
        eventsByDate[normalizedDate] = [];
      }

      // Add the event's summary to the list associated with its date.
      eventsByDate[normalizedDate]!.add(event);
    }
    // Old way
    // final prefs = await SharedPreferences.getInstance();
    // final List<String>? savedEvents = prefs.getStringList(
    //   'myEventSummariesKey',
    // );
    /* Debug print 
    if (savedEvents != null) {
      for (final event in savedEvents) {
        print("   - $event");
      }
    }
    */

    // Map of List of Workouts/Meals to DateTime
    // final Map<DateTime, List<String>> eventsByDate = {};

    // if (savedEvents != null) {
    //   for (String savedEventString in savedEvents) {
    //     try {
    //       final parts = savedEventString.split('||');
    //       // Split by date delimiter ( format: YYYY-MM-DD||workout/meal summary )
    //       // Parse date from parts[0]
    //       // If more values needed here besides date and summary
    //       // Just separate sections with delimiter and update format above
    //       final parsedDate = DateFormat('yyyy-MM-dd').parse(parts[0]);
    //       final normalizedDate = DateTime(
    //         parsedDate.year,
    //         parsedDate.month,
    //         parsedDate.day,
    //       );
    //       // Parse summary from parts[1]
    //       final summary = parts[1];

    //       // Populate key for given date
    //       if (!eventsByDate.containsKey(normalizedDate)) {
    //         eventsByDate[normalizedDate] = [];
    //       }

    //       // Add all summaries
    //       eventsByDate[normalizedDate]!.add(savedEventString);
    //     } catch (e) {
    //       print('Error processing events data: $e');
    //     }
    //   }
    // }
    return eventsByDate; // Return the populated map
  }

  /// Arrow methods
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

  /// Clickable date method
  void _selectDate(DateTime date) {
    setState(() {
      _currentDate = date;
    });
  }

  /// Navigate to Add Event Form
  void _navigateToAddEvent() async {
    await Navigator.pushNamed(context, '/add_event', arguments: _currentDate);
    // After returning from AddEventScreen, reload the events
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  /// Navigate to review event page
  void _navigateToReviewEvent(FitnessEvent event) async {
    await Navigator.pushNamed(context, '/review_event', arguments: event);
    setState(() {
      _eventsFuture = _loadEvents();
    });
  }

  Widget _buildCalendar(Map<DateTime, List<FitnessEvent>> eventsByDate) {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(
      _currentDate.year,
      _currentDate.month + 1,
      0,
    );
    final daysInMonth = lastDayOfMonth.day;
    final firstDayOfWeek = firstDayOfMonth.weekday;

    final List<Widget> calendarDays = [];

    // Initialize boxes for each day
    for (int i = 0; i < (firstDayOfWeek == 7 ? 0 : firstDayOfWeek); i++) {
      calendarDays.add(const SizedBox(width: 40.0, height: 40.0));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDateInMonth = DateTime(
        _currentDate.year,
        _currentDate.month,
        day,
      );
      final normalizedDate = DateTime(
        currentDateInMonth.year,
        currentDateInMonth.month,
        currentDateInMonth.day,
      );
      final isToday =
          currentDateInMonth.year == DateTime.now().year &&
          currentDateInMonth.month == DateTime.now().month &&
          currentDateInMonth.day == DateTime.now().day;
      final isSelected =
          currentDateInMonth.year == _currentDate.year &&
          currentDateInMonth.month == _currentDate.month &&
          currentDateInMonth.day == _currentDate.day;

      // Check for events on this date
      bool hasMeal = false;
      bool hasWorkout = false;

      // Get Events from async call for indicators
      if (eventsByDate.entries.any(
        (entry) =>
            entry.key.year == currentDateInMonth.year &&
            entry.key.month == currentDateInMonth.month &&
            entry.key.day == currentDateInMonth.day,
      )) {
        final eventsForDay = eventsByDate.entries
            .firstWhere(
              (entry) =>
                  entry.key.year == currentDateInMonth.year &&
                  entry.key.month == currentDateInMonth.month &&
                  entry.key.day == currentDateInMonth.day,
            )
            .value;
        for (final savedEvent in eventsForDay) {
          final type = savedEvent.eventType;
          if (type == EventType.meal) {
            // Check for meal
            hasMeal = true;
          }
          if (type == EventType.workout) {
            // Check for Workout session
            hasWorkout = true;
          }
        }
      }

      // Add onClick functionality
      calendarDays.add(
        GestureDetector(
          onTap: () => _selectDate(currentDateInMonth),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
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
              //  Add event indicators
              if (hasMeal)
                Positioned(
                  top: 2.0,
                  right: 2.0,
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              if (hasWorkout)
                Positioned(
                  bottom: 2.0,
                  left: 2.0,
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
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

  Widget _buildEventsList(Map<DateTime, List<FitnessEvent>> eventsByDate) {
    final normalizedSelectedDate = DateTime(
      _currentDate.year,
      _currentDate.month,
      _currentDate.day,
    );
    final eventsForSelectedDate = eventsByDate.entries
        .firstWhere(
          (entry) => entry.key == normalizedSelectedDate,
          orElse: () => MapEntry(normalizedSelectedDate, []),
        )
        .value;

    if (eventsForSelectedDate.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No events scheduled for this date.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.normal),
        ),
      );
    }

    return Column(
      children: eventsForSelectedDate.map((event) {
        var buttonText = '';
        final bool isMeal = event.eventType == EventType.meal;
        final bool isWorkout = event.eventType == EventType.workout;

        Color buttonColor = Colors.grey;
        if (isMeal) {
          buttonColor = Colors.red;
          buttonText = 'Meal';
        } else if (isWorkout) {
          buttonColor = Colors.blue;
          buttonText = 'Workout';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Card(
            color: buttonColor,
            margin: EdgeInsets.zero,
            child: InkWell(
              onTap: () => _navigateToReviewEvent(event),
              child: SizedBox(
                height: 60.0,
                child: Center(
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat(
      'EEEE, MMMM d, y',
    ).format(_currentDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BZ Fitness'),
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
      body: SingleChildScrollView(
        child: Column(
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
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
              ), // Padding from screen edges
              child: SizedBox(
                height: 60.0, // Fixed height for the dropdown container
                width: double.infinity, // Ensures it fills the available width
                child: Container(
                  // Optional: Add a background color or decoration for visual clarity
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Example background color
                    borderRadius: BorderRadius.circular(
                      10.0,
                    ), // Rounded corners
                  ),
                  child: DropdownButtonHideUnderline(
                    // Hides the default underline
                    child: DropdownButton<String>(
                      value: _selectedOption, // The currently selected value
                      isExpanded:
                          true, // Makes the dropdown fill the available width
                      dropdownColor:
                          Colors.white, // Color of the dropdown menu itself
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ), // Text style for selected item
                      // This is the indicator showing what the dropdown is for when nothing is selected.
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Show Plan', // Your indicator text
                          style: TextStyle(color: Colors.black, fontSize: 16.0),
                        ),
                      ),

                      // Custom icon for the dropdown arrow
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 16.0),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),

                      // Called when the user selects an item from the dropdown
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue;
                          print('Selected: $newValue'); // For demonstration
                        });
                      },

                      // Builds the list of items for the dropdown menu
                      items: _options.map<DropdownMenuItem<String>>((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Text(value),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Use FutureBuilder to handle the asynchronous loading of events for both calendar and event list
            FutureBuilder<Map<DateTime, List<FitnessEvent>>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading events: ${snapshot.error}'),
                  );
                } else {
                  final eventsByDate = snapshot.data ?? {};
                  return Column(
                    children: [
                      _buildEventsList(
                        eventsByDate,
                      ), // Display events for the selected date
                      const SizedBox(height: 20),
                      _buildCalendar(
                        eventsByDate,
                      ), // Call the calendar building widget
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
