// event_storage.dart (or wherever you prefer to place this class)
import 'dart:convert';
import 'package:fitness_app/model/fitness_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// Assuming all your object model classes (Identifiable, Event, EventItem, Workout, CardioWorkout, WeightliftingWorkout, Meal)
// are defined and accessible via imports in the file where EventStorage is defined.
// If they are in separate files, you'll need to import them:
// import 'path/to/your/models.dart';

class EventStorage {
  static const _eventKeysListKey =
      'event_ids'; // Key to store a list of all event IDs
  final Uuid _uuid = Uuid(); // Instantiate Uuid once

  Future<void> saveEvent(FitnessEvent event) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the Event object to a JSON string
    final eventJson = jsonEncode(event.toJson());
    // Store the JSON string using the event's unique ID as the key
    await prefs.setString(event.id, eventJson);

    // Retrieve the existing list of event IDs
    final eventIds = prefs.getStringList(_eventKeysListKey) ?? [];
    // Add the new event's ID if it's not already there (for updates)
    if (!eventIds.contains(event.id)) {
      eventIds.add(event.id);
      // Save the updated list of event IDs
      await prefs.setStringList(_eventKeysListKey, eventIds);
    }
  }

  Future<FitnessEvent?> getEvent(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    final eventJsonString = prefs.getString(eventId);
    if (eventJsonString != null) {
      // Decode the JSON string back into a Map
      final Map<String, dynamic> eventMap = jsonDecode(eventJsonString);
      // Convert the Map back into an Event object using its fromJson factory
      return FitnessEvent.fromJson(eventMap);
    }
    return null; // Return null if no event found for the given ID
  }

  Future<List<FitnessEvent>> getAllEvents() async {
    final prefs = await SharedPreferences.getInstance();
    // Get all stored event IDs
    final eventIds = prefs.getStringList(_eventKeysListKey) ?? [];
    final List<FitnessEvent> events = [];
    // For each ID, retrieve the corresponding event
    for (final id in eventIds) {
      final event = await getEvent(id);
      if (event != null) {
        events.add(event); // Add to the list if found
      }
    }
    return events;
  }

  Future<void> deleteEvent(String eventId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(eventId); // Remove the event data

    // Remove the ID from the master list
    final eventIds = prefs.getStringList(_eventKeysListKey) ?? [];
    eventIds.remove(eventId);
    await prefs.setStringList(_eventKeysListKey, eventIds);
  }

  String generateNewId() {
    return _uuid.v4(); // Generate a new UUID
  }
}
