import 'package:fitness_app/event_storage.dart';
import 'package:fitness_app/model/cardio_workout.dart';
import 'package:fitness_app/model/event_item.dart';
import 'package:fitness_app/model/fitness_event.dart';
import 'package:fitness_app/model/meal.dart';
import 'package:fitness_app/model/weightlifting_workout.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final TextEditingController _setsController = TextEditingController();
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
  // Map to hold TextEditingControllers for each dynamically displayed EventItem.
  // Key: EventItem.id, Value: Map<String, TextEditingController>
  final Map<String, Map<String, TextEditingController>> _itemControllers = {};

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

  @override
  void dispose() {
    // Dispose all controllers for the main input form
    _dateController.dispose();
    _exerciseNameController.dispose();
    _repsController.dispose();
    _setsController.dispose();
    _intensityController.dispose();
    _durationController.dispose();
    _metricValueController.dispose();
    _mealNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _noteController.dispose();

    // Dispose controllers for dynamically created EventItem fields
    _itemControllers.forEach((itemId, controllersMap) {
      controllersMap.forEach((fieldName, controller) {
        controller.dispose();
      });
    });
    super.dispose();
  }

  // Determines event type from form and adds EventItem to _currentEventItems List
  void _addEventItemToEvent() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // 1. Generate event ItemId
        final eventItemId = _eventStorage.generateNewId();

        // 2. Create nullable EventItem
        EventItem? eventItem;
        // Map to store controllers for this specific new item
        Map<String, TextEditingController> controllersForNewItem = {};

        // 2. Determine eventType for object to add
        if (_eventType == 'Workout Session') {
          if (_workoutType == 'Weight Training') {
            // Keeping eventSummary for now because it feeds the scrollableList, but
            // TODO: Change from simple string to editable fields, keep scrollableList
            // _eventSummary.add(
            //   'Weight: ${_exerciseNameController.text}, Reps: ${_repsController.text}, Intensity: ${_intensityController.text}',
            // );
            // Initialize controllers for the new WeightliftingWorkout item
            controllersForNewItem['name'] = TextEditingController(
              text: _exerciseNameController.text,
            );
            controllersForNewItem['sets'] = TextEditingController(
              text: _setsController.text,
            );
            controllersForNewItem['reps'] = TextEditingController(
              text: _repsController.text,
            );
            controllersForNewItem['intensity'] = TextEditingController(
              text: _intensityController.text,
            );

            eventItem = WeightliftingWorkout(
              id: eventItemId,
              name: _exerciseNameController.text,
              sets: int.parse(_setsController.text),
              reps: int.parse(_repsController.text),
              intensity: _intensityController.text,
              isComplete: false,
            );
          } else if (_workoutType == 'Cardio') {
            // Keeping eventSummary for now because it feeds the scrollableList, but
            // TODO: Change from simple string to editable fields, keep scrollableList
            // _eventSummary.add(
            //   'Cardio: ${_exerciseNameController.text}, Duration: ${_durationController.text}, ${_cardioMetric ?? ''}: ${_metricValueController.text}',
            // );
            // Initialize controllers for the new CardioWorkout item
            controllersForNewItem['name'] = TextEditingController(
              text: _exerciseNameController.text,
            );
            controllersForNewItem['duration'] = TextEditingController(
              text: _durationController.text,
            );
            controllersForNewItem['metric'] = TextEditingController(
              text: _cardioMetric ?? '',
            );
            controllersForNewItem['value'] = TextEditingController(
              text: _metricValueController.text,
            );

            eventItem = CardioWorkout(
              id: eventItemId,
              name: _exerciseNameController.text,
              duration: _durationController.text,
              distanceMetric: _cardioMetric ?? '',
              distanceValue: double.parse(_metricValueController.text),
              isComplete: false,
            );
          }
        }
        // Meal case
        else if (_eventType == 'Meal') {
          // Old way

          _eventSummary.add(
            'Meal: ${_mealNameController.text}, Calories: ${_caloriesController.text}, Protein: ${_proteinController.text}g, Carbs: ${_carbsController.text}g, Fat: ${_fatController.text}g, Note: ${_noteController.text}',
          );

          // New way
          eventItem = Meal(
            id: eventItemId,
            name: _mealNameController.text,
            calories: int.parse(_caloriesController.text),
            protein: int.parse(_proteinController.text),
            carbs: int.parse(_carbsController.text),
            fat: int.parse(_fatController.text),
            notes: _noteController.text,
            isComplete: false,
          );
          // Initialize controllers for the new Meal item
          controllersForNewItem['name'] = TextEditingController(
            text: _mealNameController.text,
          );
          controllersForNewItem['calories'] = TextEditingController(
            text: _caloriesController.text,
          );
          controllersForNewItem['protein'] = TextEditingController(
            text: _proteinController.text,
          );
          controllersForNewItem['carbs'] = TextEditingController(
            text: _carbsController.text,
          );
          controllersForNewItem['fat'] = TextEditingController(
            text: _fatController.text,
          );
          controllersForNewItem['notes'] = TextEditingController(
            text: _noteController.text,
          );
        } else {
          // Shouldn't happen since it's handled by dropdown
          throw Exception("Unable to determine valid EventType");
        }
        // 4. Add eventItem to currentEventItems, assert
        _currentEventItems.add(eventItem!);
        _itemControllers[eventItemId] = controllersForNewItem;
      });
    }
  }

  /// saves to SharedPreferences using the entire string as the key
  Future<void> _saveEvent() async {
    // New way
    if (_currentEventItems.isNotEmpty) {
      // 1. Get the Event Date
      DateTime? eventDate;
      try {
        if (_dateController.text.isNotEmpty) {
          eventDate = DateTime.parse(_dateController.text);
        } else {
          eventDate = DateTime.now(); // Default to current date
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
        eventDate: eventDate!,
        eventType: selectedEventType,
        eventItems:
            _currentEventItems, // Use the list of actual EventItem objects
        isComplete: false, // Default to not complete
      );

      print(newEvent.toJson().toString());
      // 5. Save the Event object using the EventStorage helper
      try {
        await _eventStorage.saveEvent(newEvent);

        // Debugging: retrieve and print to verify
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
  }

  // Helper method to build a row of TextFormFields for an EventItem
  Widget _buildEventItemRow(EventItem item, int index) {
    // Retrieve the controllers for this specific item.
    // We assert non-null because controllers are initialized when item is added.
    final itemControllers = _itemControllers[item.id]!;

    List<Widget> fields = [];
    String itemTitle = '';

    // Determine the type of EventItem and build appropriate TextFormFields
    if (item is WeightliftingWorkout) {
      itemTitle = 'Weightlifting: ';
      fields.addAll([
        SizedBox(
          child: TextFormField(
            controller: itemControllers['name'],
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) {
              setState(() {
                item.name = value;
              });
            },
          ),
        ),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['sets'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Sets'),
            onChanged: (value) {
              setState(() {
                item.sets = int.tryParse(value) ?? item.sets;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['reps'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Reps'),
            onChanged: (value) {
              setState(() {
                item.reps = int.tryParse(value) ?? item.reps;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['intensity'],
            decoration: const InputDecoration(labelText: 'Intensity'),
            onChanged: (value) {
              setState(() {
                item.intensity = value;
              });
            },
          ),
        ),
      ]);
    } else if (item is CardioWorkout) {
      itemTitle = 'Cardio: ';
      fields.addAll([
        SizedBox(
          child: TextFormField(
            controller: itemControllers['name'],
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) {
              setState(() {
                item.name = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['duration'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Duration'),
            onChanged: (value) {
              setState(() {
                item.duration = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['metric'],
            decoration: const InputDecoration(labelText: 'Metric'),
            onChanged: (value) {
              setState(() {
                item.distanceMetric = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['value'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Value'),
            onChanged: (value) {
              setState(() {
                item.distanceValue =
                    double.tryParse(value) ?? item.distanceValue;
              });
            },
          ),
        ),
      ]);
    } else if (item is Meal) {
      itemTitle = 'Meal: ';
      fields.addAll([
        SizedBox(
          child: TextFormField(
            controller: itemControllers['name'],
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (value) {
              setState(() {
                item.name = value;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['calories'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Calories'),
            onChanged: (value) {
              setState(() {
                item.calories = int.tryParse(value) ?? item.calories;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['protein'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Protein'),
            onChanged: (value) {
              setState(() {
                item.protein = int.tryParse(value) ?? item.protein;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['carbs'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Carbs'),
            onChanged: (value) {
              setState(() {
                item.carbs = int.tryParse(value) ?? item.carbs;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['fat'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Fat'),
            onChanged: (value) {
              setState(() {
                item.fat = int.tryParse(value) ?? item.fat;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          child: TextFormField(
            controller: itemControllers['notes'],
            maxLines: 1, // Keep it single line in summary for compactness
            decoration: const InputDecoration(labelText: 'Notes'),
            onChanged: (value) {
              setState(() {
                item.notes = value;
              });
            },
          ),
        ),
      ]);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$itemTitle ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      // Dispose controllers for the item being removed
                      _itemControllers[item.id]?.forEach((
                        fieldName,
                        controller,
                      ) {
                        controller.dispose();
                      });
                      _itemControllers.remove(
                        item.id,
                      ); // Remove from controller map
                      _currentEventItems.removeAt(
                        index,
                      ); // Remove from event items list
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Use Wrap for better responsiveness and flow of text fields
            Wrap(
              spacing: 8.0, // horizontal spacing between items
              runSpacing: 8.0, // vertical spacing between lines
              children: fields,
            ),
          ],
        ),
      ),
    );
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
                    controller: _setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Sets',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of sets';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
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
                  onPressed: _addEventItemToEvent,
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
                  onPressed: _addEventItemToEvent,
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
              // Display EventItems as editable rows
              SizedBox(
                height:
                    200.0, // Increased height for better visibility of multiple rows
                child: _currentEventItems.isEmpty
                    ? Text(
                        'No ${_eventType == 'Meal' ? 'meals' : 'exercises'} added yet.',
                      )
                    : ListView.builder(
                        itemCount: _currentEventItems.length,
                        itemBuilder: (context, index) {
                          // Build and return the editable row for each EventItem
                          return _buildEventItemRow(
                            _currentEventItems[index],
                            index,
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _currentEventItems.isNotEmpty ? _saveEvent : null,
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
