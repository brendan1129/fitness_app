import 'package:fitness_app/event_storage.dart';
import 'package:fitness_app/model/cardio_workout.dart';
import 'package:fitness_app/model/event_item.dart';
import 'package:fitness_app/model/fitness_event.dart';
import 'package:fitness_app/model/meal.dart';
import 'package:fitness_app/model/weightlifting_workout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddEventScreen extends StatefulWidget {
  /// Take in selectedDate from home page
  const AddEventScreen({super.key, this.selectedDate});

  final DateTime? selectedDate;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  /// Controllers and field values
  /// [eventType] - Workout Session or Meal
  /// TODO: eventParent - Plan that Workout or Meal pertains to
  ///   Should be preloaded from calendar screen
  /// [dateController] - Controls Date Field Content
  /// [workoutType] - Weight Training or Cardio
  /// [exerciseName] - Name of Lift
  /// [reps] - Number of reps for lift
  /// [intensity] - Intensity measurement ( i.e. RPE, rep speed )
  /// [duration] - duration for cardio
  /// [cardioMetric] - Metric for tracking cardio ( i.e. miles, time, # steps, calories burned )
  /// [metricValue] - value of cardio-tracking metric ( i.e. 1 mile, 5 minutes )
  /// [mealName] - Name of Meal
  /// [calories], [protein], [carbs], [fat] - Macros of Meal
  /// [note] - Actual contents of meal if necessary
  String? _eventType;
  final TextEditingController _dateController = TextEditingController();
  String? _workoutType;
  final TextEditingController _exerciseNameController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _intensityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  String? _cardioMetric;
  final TextEditingController _metricValueController = TextEditingController();
  final TextEditingController _mealNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // Old simple string version
  final List<String> _eventSummary = [];
  // New OOP version
  final List<EventItem> _currentEventItems = [];
  // Form object for Workouts and Meals
  final _formKey = GlobalKey<FormState>();

  // Event storage manager
  final EventStorage _eventStorage = EventStorage();

  @override
  void initState() {
    super.initState();
    _dateController.text = widget.selectedDate != null
        ? DateFormat('yyyy-MM-dd').format(widget.selectedDate!)
        : '';
  }

  // Determines event type from form and adds to _eventSummary List
  void _addEventToSummary() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Workout session case
        final eventItemId = _eventStorage.generateNewId();
        if (_eventType == 'Workout Session') {
          if (_workoutType == 'Weight Training') {
            // Old way

            _eventSummary.add(
              'Weight: ${_exerciseNameController.text}, Reps: ${_repsController.text}, Intensity: ${_intensityController.text}',
            );

            // New way
            _currentEventItems.add(
              WeightliftingWorkout(
                id: eventItemId,
                name: _exerciseNameController.text,
                reps: int.parse(_repsController.text),
                intensity: _intensityController.text,
                isComplete: false,
              ),
            );
          } else if (_workoutType == 'Cardio') {
            // Old way

            _eventSummary.add(
              'Cardio: ${_exerciseNameController.text}, Duration: ${_durationController.text}, ${_cardioMetric ?? ''}: ${_metricValueController.text}',
            );

            // New way
            _currentEventItems.add(
              CardioWorkout(
                id: eventItemId,
                name: _exerciseNameController.text,
                duration: _durationController.text,
                distanceMetric: _cardioMetric ?? '',
                distanceValue: double.parse(_metricValueController.text),
                isComplete: false,
              ),
            );
          }
          // Do not clear fields after add
          //_exerciseNameController.clear();
          //_repsController.clear();
          //_intensityController.clear();
          //_durationController.clear();
          //_metricValueController.clear();
        }
        // Meal case
        else if (_eventType == 'Meal') {
          // Old way

          _eventSummary.add(
            'Meal: ${_mealNameController.text}, Calories: ${_caloriesController.text}, Protein: ${_proteinController.text}g, Carbs: ${_carbsController.text}g, Fat: ${_fatController.text}g, Note: ${_noteController.text}',
          );

          // New way
          _currentEventItems.add(
            Meal(
              id: eventItemId,
              name: _mealNameController.text,
              calories: int.parse(_caloriesController.text),
              protein: int.parse(_proteinController.text),
              carbs: int.parse(_carbsController.text),
              fat: int.parse(_fatController.text),
              notes: _noteController.text,
              isComplete: false,
            ),
          );
          // Do not clear fields after add
          //_mealNameController.clear();
          //_caloriesController.clear();
          //_proteinController.clear();
          //_carbsController.clear();
          //_fatController.clear();
          //_noteController.clear();
        }
      });
    }
  }

  /// saves to SharedPreferences using the entire string as the key
  Future<void> _saveEvent() async {
    /**
    * TODO: Build event object instead of saving string.
    */
    // New way
    if (_eventSummary.isNotEmpty) {
      // 1. Get the Event Date
      DateTime? eventDate;
      try {
        if (_dateController.text.isNotEmpty) {
          // Parse the date from the controller. Ensure the format is consistent (e.g., ISO 8601 or your app's standard)
          // For simplicity, assuming a simple date format that DateTime.parse can handle directly,
          // or you might use intl package for more robust parsing.
          eventDate = DateTime.parse(_dateController.text);
        } else {
          // Handle case where date is not selected (e.g., show error or default to now)
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select a date for the event.'),
              ),
            );
          }
          return; // Stop saving if date is missing
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid date format: ${e.toString()}')),
          );
        }
        return; // Stop saving on date parsing error
      }

      // 2. Determine EventType (Workout or Meal)
      EventType selectedEventType;
      if (_eventType == 'Workout Session') {
        selectedEventType = EventType.workout;
      } else if (_eventType == 'Meal') {
        selectedEventType = EventType.meal;
      } else {
        // This case should ideally not happen if _eventType is always controlled by UI
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid event type selected.')),
          );
        }
        return;
      }

      // 3. Generate a unique ID for the new Event
      final newEventId = _eventStorage.generateNewId();

      // 4. Create the Event object
      final newEvent = FitnessEvent(
        id: newEventId,
        eventDate: DateFormat('yyyy-MM-dd').parse(_dateController.text),
        eventType: selectedEventType,
        eventItems:
            _currentEventItems, // Use the list of actual EventItem objects
        isComplete: false, // Default to not complete
      );

      // 5. Save the Event object using the EventStorage helper
      try {
        await _eventStorage.saveEvent(newEvent);

        // Debugging: you can retrieve and print to verify
        // final savedEvent = await _eventStorage.getEvent(newEvent.id);
        // print('Successfully saved Event with ID: ${savedEvent?.id}');
        // print('Event data: ${savedEvent?.toJson()}');

        // Check if the widget is still in the tree before using BuildContext
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${selectedEventType == EventType.meal ? 'Meal' : 'Workout'} saved!',
              ),
            ),
          );
          Navigator.pop(context); // Pop the screen after successful save
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving event: ${e.toString()}')),
          );
        }
      }
    } else {
      // No event items were added
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please add at least one ${_eventType == 'Meal' ? 'meal' : 'exercise'}.',
            ),
          ),
        );
      }
    }
    // Old way
    // if (_eventSummary.isNotEmpty) {
    //   final prefs = await SharedPreferences.getInstance();

    //   // Insert date at the beginning of the list for calendar building
    //   String formattedDate = '';
    //   if (_dateController.text != '') {
    //     /// Add [delimiter] after DateTime for delimiting later
    //     /// Maybe make this global in the future
    //     String delimiter = '||';

    //     /// '_dateController.text' should have the date selected from calendar filled and
    //     /// unable to be edited
    //     formattedDate = _dateController.text + delimiter;
    //   } else {
    //     formattedDate = "Invalid Date||"; // Or handle this more gracefully
    //     // Nevermind, that's plenty graceful
    //   }

    //   // Join summaries with a comma and space
    //   String allSummaries = _eventSummary.join(', ');
    //   final combinedString =
    //       formattedDate + allSummaries; // Combine date and all summaries
    //   // Debug, remove later
    //   for (final item in _eventSummary) {
    //     print("Saving to SharedPreferences: $item");
    //   }
    //   // Set event summary in prefs
    //   // 1. Retrieve the existing list (if any)
    //   List<String>? existingList =
    //       prefs.getStringList('myEventSummariesKey') ??
    //       []; // Default to empty list

    //   // 2. Add the new element
    //   existingList.add(combinedString);

    //   // 3. Save the entire updated list
    //   await prefs.setStringList('myEventSummariesKey', existingList);
    //   // Check if the widget is still in the tree before using BuildContext
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           '${_eventType == 'Meal' ? 'Meal' : 'Workout'} saved!',
    //         ),
    //       ),
    //     );
    //     Navigator.pop(context);
    //   }
    // } else {
    //   // Check if the widget is still in the tree before using BuildContext
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //         content: Text(
    //           'Please add at least one ${_eventType == 'Meal' ? 'meal' : 'exercise'}.',
    //         ),
    //       ),
    //     );
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Event'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                enabled: false,
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                ),
                value: _eventType,
                items: <String>['Workout Session', 'Meal'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    if (_eventType != newValue) {
                      _eventSummary
                          .clear(); // Clear summary when event type changes
                    }
                    _eventType = newValue;
                    _workoutType =
                        null; // Reset workout type when event type changes
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an event type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_eventType == 'Workout Session') ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Workout Type',
                    border: OutlineInputBorder(),
                  ),
                  value: _workoutType,
                  items: <String>['Cardio', 'Weight Training'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _workoutType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a workout type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_workoutType == 'Weight Training') ...[
                  TextFormField(
                    controller: _exerciseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the exercise name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of reps';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _intensityController,
                    decoration: const InputDecoration(
                      labelText: 'Intensity (e.g., weight, resistance)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the intensity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
                if (_workoutType == 'Cardio') ...[
                  TextFormField(
                    controller: _exerciseNameController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the exercise name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duration (in minutes)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the duration';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Tracking Metric',
                      border: OutlineInputBorder(),
                    ),
                    value: _cardioMetric,
                    items: <String>['Speed', 'Intensity', 'Distance', 'Other']
                        .map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        })
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _cardioMetric = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a tracking metric';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _metricValueController,
                    decoration: InputDecoration(
                      labelText: 'Value (${_cardioMetric ?? ''})',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the value';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
                ElevatedButton(
                  onPressed: _addEventToSummary,
                  child: const Text('Add Workout'),
                ),
                const SizedBox(height: 20),
              ],
              if (_eventType == 'Meal') ...[
                TextFormField(
                  controller: _mealNameController,
                  decoration: const InputDecoration(
                    labelText: 'Meal Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the meal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the calories';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Protein (g)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the protein amount';
                    }
                    if (num.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _carbsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Carbs (g)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the carbs amount';
                    }
                    if (num.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _fatController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Fat (g)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the fat amount';
                    }
                    if (num.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addEventToSummary,
                  child: const Text('Add Meal'),
                ),
                const SizedBox(height: 20),
              ],
              Text(
                '${_eventType == 'Meal' ? 'Meal' : 'Workout'} Summary:',
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 100.0,
                child: _eventSummary.isEmpty
                    ? Text(
                        'No ${_eventType == 'Meal' ? 'meals' : 'exercises'} added yet.',
                      )
                    : ListView.builder(
                        itemCount: _eventSummary.length,
                        itemBuilder: (context, index) {
                          return Text(_eventSummary[index]);
                        },
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _eventSummary.isNotEmpty ? _saveEvent : null,
                child: Text(
                  'Save ${_eventType == 'Meal' ? 'Meal' : 'Workout'}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
