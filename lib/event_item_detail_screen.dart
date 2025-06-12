import 'package:fitness_app/event_storage.dart';
import 'package:fitness_app/model/fitness_event.dart';
import 'package:fitness_app/model/event_item.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Recommended graph package (see Part 5)

// For unique EventItem IDs, used to track notes for a specific item
import 'package:uuid/uuid.dart';

class EventItemDetailScreen extends StatefulWidget {
  final FitnessEvent currentEvent; // The parent event
  final EventItem initialEventItem; // The specific item being viewed
  final int initialItemIndex; // The index of the item within the event's list
  final ValueChanged<FitnessEvent>
  onEventUpdated; // Callback to update parent event

  const EventItemDetailScreen({
    super.key,
    required this.currentEvent,
    required this.initialEventItem,
    required this.initialItemIndex,
    required this.onEventUpdated,
  });

  @override
  State<EventItemDetailScreen> createState() => _EventItemDetailScreenState();
}

class _EventItemDetailScreenState extends State<EventItemDetailScreen> {
  late FitnessEvent _currentEvent;
  late EventItem _currentEventItem;
  late int _currentItemIndex;
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  final EventStorage _eventStorage = EventStorage();
  final _formKey = GlobalKey<FormState>(); // For validation if you add it

  @override
  void initState() {
    super.initState();
    _currentEvent = widget.currentEvent;
    _currentItemIndex = widget.initialItemIndex;
    _currentEventItem = widget.currentEvent.eventItems[_currentItemIndex];
    _nameController = TextEditingController(text: _currentEventItem.name);
    _notesController = TextEditingController(
      text: _currentEventItem.notes,
    ); // Assuming notes field added to EventItem
  }

  @override
  void didUpdateWidget(covariant EventItemDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the event or item changes from parent, update controllers
    if (widget.initialEventItem.id != oldWidget.initialEventItem.id) {
      _currentEvent = widget.currentEvent;
      _currentItemIndex = widget.initialItemIndex;
      _currentEventItem = widget.currentEvent.eventItems[_currentItemIndex];
      _nameController.text = _currentEventItem.name;
      _notesController.text = _currentEventItem.notes;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveEventItemChanges() async {
    // Update the EventItem with new values
    _currentEventItem.name = _nameController.text;
    _currentEventItem.notes = _notesController.text;

    // Update the parent event's item in its list
    widget.currentEvent.eventItems[_currentItemIndex] = _currentEventItem;

    // Call the callback to inform the parent (StartEventScreen) to update and save
    widget.onEventUpdated(widget.currentEvent);

    // if (mounted) {
    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(const SnackBar(content: Text('Event Item saved!')));
    // }
  }

  void _navigateToItem(int direction) {
    // direction: 1 for next, -1 for previous
    int newIndex = _currentItemIndex + direction;
    if (newIndex >= 0 && newIndex < widget.currentEvent.eventItems.length) {
      setState(() {
        _saveEventItemChanges(); // Save current item's changes before navigating
        _currentItemIndex = newIndex;
        _currentEventItem = widget.currentEvent.eventItems[_currentItemIndex];
        _nameController.text = _currentEventItem.name;
        _notesController.text = _currentEventItem.notes;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newIndex < 0 ? 'No previous item' : 'No next item'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // Placeholder for a simple graph
  Widget _buildGraphSection() {
    // When using SingleChildScrollView, avoid Expanded directly in the main Column's children
    // Instead, give children a defined height or allow them to take intrinsic height.
    // For graphs, a defined height often works well.
    return Container(
      height: 180, // Explicit height for the graph section
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Metric for ${_currentEventItem.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Expanded(
            // Expanded within its parent Container (which has fixed height)
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 2),
                      FlSpot(2, 5),
                      FlSpot(3, 3.5),
                      FlSpot(4, 4.5),
                      FlSpot(5, 1),
                    ],
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(
        12.0,
      ), // Slightly more padding for better look
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Item Details:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Item Name',
              border: OutlineInputBorder(), // Add border for better visual
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 12.0,
              ),
            ),
            style: const TextStyle(fontSize: 16), // A bit larger text
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Type: ${_currentEvent.eventType.toString().split('.').last}',
                style: const TextStyle(fontSize: 16),
              ),
              const Spacer(),
              Checkbox(
                value: _currentEventItem.isComplete,
                onChanged: (bool? newValue) {
                  setState(() {
                    _currentEventItem.isComplete = newValue ?? false;
                    _saveEventItemChanges();
                  });
                },
              ),
              const Text('Completed', style: TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12), // Added some spacing at the bottom
        ],
      ),
    );
  }

  Widget _buildVideoNotesSection() {
    // We want this section to fill the remaining vertical space.
    // So, we'll return a Column, which is a vertical layout widget,
    // and this Column will be expanded by its parent.
    // Inside this Column, we will put the Row that splits video and notes horizontally.
    return Column(
      children: [
        Expanded(
          // This Expanded makes the Row fill the vertical space within this Column
          child: Row(
            crossAxisAlignment: CrossAxisAlignment
                .stretch, // <--- KEY CHANGE: Forces children to stretch vertically
            children: [
              // Left half: Video Placeholder
              Expanded(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.ondemand_video,
                          size: 50,
                          color: Colors.white70,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Video Player Placeholder',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Right half: Notes Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes/Reflections:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // This Expanded ensures the TextField fills available height within this Column
                      Expanded(
                        child: TextField(
                          controller: _notesController,
                          maxLines: null, // Allows multiline input
                          expands:
                              true, // TextField expands to fill available height
                          keyboardType: TextInputType.multiline,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            hintText: 'Enter your notes here...',
                            border: OutlineInputBorder(),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 12.0,
                            ),
                          ),
                          style: const TextStyle(fontSize: 16),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_currentEventItem.name} View'),
        backgroundColor: Colors.black,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SizedBox.expand(
        // <--- Wrap the Column in SingleChildScrollView
        child: IntrinsicHeight(
          // <--- Use IntrinsicHeight to allow Flexible/Expanded children to size correctly
          child: Column(
            children: [
              _buildGraphSection(),
              _buildDetailsSection(),
              Expanded(
                child:
                    _buildVideoNotesSection(), // This Expanded will now take available height in IntrinsicHeight
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: _currentItemIndex > 0
                  ? () => _navigateToItem(-1)
                  : null,
              tooltip: 'Previous Item',
            ),
            Text(
              '${_currentItemIndex + 1} / ${widget.currentEvent.eventItems.length}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
              onPressed:
                  _currentItemIndex < widget.currentEvent.eventItems.length - 1
                  ? () => _navigateToItem(1)
                  : null,
              tooltip: 'Next Item',
            ),
          ],
        ),
      ),
    );
  }
}
