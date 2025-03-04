import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../database/database_helper.dart';

class HomePage extends StatefulWidget {
  final int userId;
  final String userName;
  final String userType;

  HomePage({
    required this.userId,
    required this.userName,
    required this.userType,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<String>> _events = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Load events when the page is first loaded
  }

  // Method to load events from the database
  void _loadEvents() async {
    String dateStr = _selectedDay.toIso8601String().split('T')[0];
    List<Map<String, dynamic>> eventList = await DatabaseHelper().getEvents(
      widget.userId,
      dateStr,
    );

    setState(() {
      _events[_selectedDay] =
          eventList.map((event) => event['event'] as String).toList();
    });
  }

  // Method to add event
  void _addEvent(String event) async {
    // Save the event in the local list
    setState(() {
      if (_events[_selectedDay] == null) {
        _events[_selectedDay] = [];
      }
      _events[_selectedDay]!.add(event);
    });

    // Save the event in the database
    String dateStr = _selectedDay.toIso8601String().split('T')[0];
    await DatabaseHelper().insertEvent(widget.userId, dateStr, event);
  }

  // Method to delete event
  void _deleteEvent(String event) async {
    String dateStr = _selectedDay.toIso8601String().split('T')[0];

    // Remove the event from the local list
    setState(() {
      _events[_selectedDay]?.remove(event);
    });

    // Delete the event from the database
    await DatabaseHelper().deleteEvent(widget.userId, dateStr, event);
  }

  // Confirmation Dialog before deletion
  void _showDeleteConfirmationDialog(String event) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Deletion"),
            content: Text("Are you sure you want to delete this event?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog without deletion
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  _deleteEvent(event); // Proceed with deletion
                  Navigator.pop(context); // Close the dialog
                },
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _onItemTapped(int index) {
    String route;
    switch (index) {
      case 0:
        route = '/home';
        break;
      case 1:
        route = '/inbox';
        break;
      case 2:
        route = '/download';
        break;
      case 3:
        route = '/profile';
        break;
      default:
        return;
    }

    if (route == '/profile') {
      Navigator.pushNamed(
        context,
        route,
        arguments: {'userId': widget.userId}, // Pass userId inside a map
      );
    } else {
      if (ModalRoute.of(context)?.settings.name != route) {
        Navigator.pushNamed(context, route);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
              _loadEvents(); // Load events when a new day is selected
            },
          ),
          ElevatedButton(
            onPressed: _showAddEventDialog,
            child: Text("Add Important Date"),
          ),
          Expanded(
            child: ListView(
              children:
                  _events[_selectedDay]
                      ?.map(
                        (event) => ListTile(
                          title: Text(event),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            color: Colors.red, // Red color for delete icon
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                event,
                              ); // Show confirmation dialog
                            },
                          ),
                        ),
                      )
                      .toList() ??
                  [],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Download',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  void _showAddEventDialog() {
    TextEditingController _eventController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Add Important Date"),
            content: TextField(
              controller: _eventController,
              decoration: InputDecoration(hintText: "Enter event name"),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  if (_eventController.text.isNotEmpty) {
                    _addEvent(_eventController.text);
                  }
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }
}
