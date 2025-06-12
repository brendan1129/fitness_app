// event_checklist_screen.dart
import 'package:fitness_app/event_item_detail_screen.dart';
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
    _currentEvent.isComplete = _currentEvent.eventItems.every(
      (item) => item.isComplete,
    );
    _saveEventChanges(true); // Save changes to storage immediately
  }

  // This callback will be passed to EventItemDetailScreen to update _currentEvent
  void _onEventItemUpdated(FitnessEvent updatedEvent) {
    setState(() {
      _currentEvent = updatedEvent;
      // You might also check here if all items are completed to update _currentEvent.isCompleted
      _currentEvent.isComplete = _currentEvent.eventItems.every(
        (item) => item.isComplete,
      );
    });
    _saveEventChanges(false); // Save changes to storage
  }

  Future<void> _saveEventChanges(bool logEnabled) async {
    try {
      await _eventStorage.saveEvent(_currentEvent);
      if (mounted && logEnabled) {
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
        title: Text('${_currentEvent.eventName} Checklist'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentEvent.isComplete
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: _currentEvent.isComplete
                  ? Colors.greenAccent
                  : Colors.white,
            ),
            tooltip: _currentEvent.isComplete
                ? 'Event Completed'
                : 'Event Not Completed',
            onPressed: () {
              // Optionally allow toggling event completion from here
              setState(() {
                _currentEvent.isComplete = !_currentEvent.isComplete;
              });
              _saveEventChanges(true);
            },
          ),
        ],
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
                  child: ListTile(
                    // Changed from CheckboxListTile to ListTile
                    onTap: () async {
                      // Navigate to the detail screen for this item
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventItemDetailScreen(
                            currentEvent:
                                _currentEvent, // Pass the entire event
                            initialEventItem: item,
                            initialItemIndex: index,
                            onEventUpdated:
                                _onEventItemUpdated, // Pass the callback
                          ),
                        ),
                      );
                      // If result is not null (e.g., a specific return from the detail screen)
                      // you can handle it here if needed, but the callback already updates state.
                    },
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
                          ? 'Workout'
                          : 'Meal',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing:
                        item
                            .isComplete // Conditional checkmark
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null, // No icon if not completed
                  ),
                );
              },
            ),
    );
  }
}
