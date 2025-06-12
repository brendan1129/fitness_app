import 'package:fitness_app/event_storage.dart';
import 'package:fitness_app/model/fitness_event.dart'; // Assuming FitnessEvent is your Event class
import 'package:fitness_app/play_event_screen.dart';
import 'package:flutter/material.dart';

class ReviewEventScreen extends StatefulWidget {
  final FitnessEvent event; // Now accessed via widget.event

  const ReviewEventScreen({super.key, required this.event});

  @override
  State<ReviewEventScreen> createState() => _ReviewEventScreenState();
}

class _ReviewEventScreenState extends State<ReviewEventScreen> {
  final EventStorage _eventStorage = EventStorage();

  // Declare TextEditingControllers
  late TextEditingController _eventNameController;
  late TextEditingController _eventDateController;

  @override
  void initState() {
    super.initState();
    // 2. Initialize controllers with values from the passed `Event` object
    _eventNameController = TextEditingController(text: widget.event.eventName);
    // For DateTime, you'll likely want to format it into a displayable string
    _eventDateController = TextEditingController(
      text: widget.event.eventDate.toLocal().toIso8601String().split('T')[0],
    );
  }

  @override
  void didUpdateWidget(covariant ReviewEventScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 3. Update controllers if the `event` object itself changes (e.g., if this widget is rebuilt with a different event)
    if (widget.event.id != oldWidget.event.id) {
      _eventNameController.text = widget.event.eventName;
      _eventDateController.text = widget.event.eventDate
          .toLocal()
          .toIso8601String()
          .split('T')[0];
      // If you allow changing the selection while on this page,
      // you might also want to update the selection to the end of the text.
      _eventNameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _eventNameController.text.length),
      );
      _eventDateController.selection = TextSelection.fromPosition(
        TextPosition(offset: _eventDateController.text.length),
      );
    }
  }

  @override
  void dispose() {
    // 4. Dispose controllers when the State object is removed from the tree
    _eventNameController.dispose();
    _eventDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the event via `widget.event`
    final FitnessEvent event = widget.event;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black, // Change your color here
        ),
        title: const Text('Review & Start Event'),
        backgroundColor: Colors.grey,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
          shadows: <Shadow>[
            Shadow(
              blurRadius: 16.0,
              color: Colors.black,
              offset: Offset(0.0, 0.0),
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Event Details:',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                event.getSummary(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              Text("Completed: ${event.isComplete.toString()}"),
              const SizedBox(height: 16),
              TextField(
                controller: _eventDateController,
                decoration: const InputDecoration(
                  labelText: 'Event Date (YYYY-MM-DD)',
                ),
                // You might make this read-only and use a DatePicker
                readOnly: true,
                onTap: () async {
                  // Example: Open a date picker
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _eventDateController.text = pickedDate
                        .toIso8601String()
                        .split('T')[0];
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eventNameController,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the event name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Navigate to the new EventChecklistScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlayEventScreen(event: widget.event),
                    ),
                  );
                },
                child: const Text('Start Event'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  String updatedName = _eventNameController.text;
                  DateTime updatedDate = DateTime.parse(
                    _eventDateController.text,
                  );

                  widget.event.eventDate = updatedDate;
                  widget.event.eventName = updatedName;

                  print('Updated Name: $updatedName');
                  print('Updated Date: $updatedDate');

                  // Call the save method and handle success/failure
                  try {
                    await _eventStorage.saveEvent(
                      widget.event,
                    ); // Await the save operation

                    // Show success SnackBar AFTER the save is complete
                    // Check `mounted` to ensure the widget is still in the tree
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Event saved successfully!'),
                        duration: Duration(
                          seconds: 2,
                        ), // How long the SnackBar is visible
                      ),
                    );
                    // Optionally, navigate back to the previous screen after savingR
                  } catch (e) {
                    // Show error SnackBar if something went wrong during save
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to save event: ${e.toString()}',
                          ),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save Changes'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirm Deletion'),
                        content: const Text(
                          'Are you sure you want to delete this event? This action cannot be undone.',
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, false);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext, true);
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmDelete == true) {
                    try {
                      // Access event via `widget.event.id`
                      await _eventStorage.deleteEvent(widget.event.id);

                      // `mounted` is now correctly recognized here
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Event deleted successfully!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error deleting event: $e'),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Deletion cancelled.'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Delete Event'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to the previous screen
                },
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
