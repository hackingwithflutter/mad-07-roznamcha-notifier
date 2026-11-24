import 'entry.dart';

/// Eight entries to fill the list until the app can save real ones (week 8).
/// They are in the order they were written: the oldest first.
///
/// `List.unmodifiable` makes a list that refuses `add`, `remove` and `sort`,
/// so no code can change the sample data by accident.
final List<Entry> sampleEntries = List.unmodifiable([
  Entry(
    id: 1,
    title: 'First day of the semester',
    body: 'New timetable, new room, and the same long queue at the canteen.',
    date: DateTime(2026, 11, 2),
    mood: Mood.okay,
  ),
  Entry(
    id: 2,
    title: 'Chai with Zain',
    body: 'We sat at the dhaba after class and planned our app. Two cups each.',
    date: DateTime(2026, 11, 5),
    mood: Mood.happy,
  ),
  Entry(
    id: 3,
    title: 'Load shedding again',
    body: 'No light for three hours. I read my notes by the torch on my phone.',
    date: DateTime(2026, 11, 8),
    mood: Mood.sad,
  ),
  Entry(
    id: 4,
    title: 'Cricket after class',
    body: 'Fatima hit a six over the wall. We lost the ball and the match.',
    date: DateTime(2026, 11, 11),
    mood: Mood.happy,
  ),
  Entry(
    id: 5,
    title: 'Too much chai',
    body: 'Four cups before the lab. I could not sleep until two.',
    date: DateTime(2026, 11, 13),
    mood: Mood.okay,
  ),
  Entry(
    id: 6,
    title: 'Biryani on Sunday',
    body: 'Nani cooked for everyone. I ate two plates and then slept.',
    date: DateTime(2026, 11, 15),
    mood: Mood.happy,
  ),
  Entry(
    id: 7,
    title: 'Quiz went badly',
    body: 'I mixed up Row and Column again. I will draw the tree next time.',
    date: DateTime(2026, 11, 18),
    mood: Mood.sad,
  ),
  Entry(
    id: 8,
    title: 'Rain in Lahore',
    body: 'The first rain of the winter. The whole street smelled of pakoras.',
    date: DateTime(2026, 11, 20),
    mood: Mood.happy,
  ),
]);
