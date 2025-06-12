// event_checklist_screen.dart
import 'package:fitness_app/event_storage.dart';
import 'package:fitness_app/model/fitness_event.dart'; // Import FitnessEvent
import 'package:fitness_app/model/event_item.dart'; // Import EventItem
import 'package:flutter/material.dart';

class PlayEventScreen extends StatefulWidget {
  final FitnessEvent event;

  const PlayEventScreen({super.key, required this.event});

  @override
  State<PlayEventScreen> createState() => _PlayEventScreenState();
}

class _PlayEventScreenState extends State<PlayEventScreen> {
  late FitnessEvent _currentEvent; // Use a mutable copy of the event
  final EventStorage _eventStorage = EventStorage();

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.event;
  }

  void _toggleItemCompletion(EventItem item, bool? isComplete) {
    setState(() {
      item.isComplete = isComplete ?? false;
      // Update the actual event object as well, for persistence
      _currentEvent.updateEventItemCompletion(item.id, isComplete ?? false);
    });
    _currentEvent.isComplete = _isEventComplete(_currentEvent.eventItems);
    _saveEventChanges(); // Save changes to storage immediately
  }

  // Helper for checking event completion
  bool _isEventComplete(List<EventItem> events) {
    for (EventItem i in events) {
      if (!i.isComplete) {
        return false;
      }
    }
    return true;
  }

  Future<void> _saveEventChanges() async {
    try {
      await _eventStorage.saveEvent(_currentEvent);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event progress saved!'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save progress: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Activity: ${_currentEvent.eventName}'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: _currentEvent.eventItems.isEmpty
          ? const Center(
              child: Text(
                'No workouts or meals defined for this event yet.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _currentEvent.eventItems.length,
              itemBuilder: (context, index) {
                final item = _currentEvent.eventItems[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  child: CheckboxListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        decoration: item.isComplete
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.isComplete ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      _currentEvent.eventType == EventType.workout
                          ? 'Exercise'
                          : 'Meal Item',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    value: item.isComplete,
                    onChanged: (bool? newValue) {
                      _toggleItemCompletion(item, newValue);
                    },
                  ),
                );
              },
            ),
    );
  }
}
