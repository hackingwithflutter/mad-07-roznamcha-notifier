# Roznamcha: week 7 starter (step 5)

This is Roznamcha, the course app of Mobile Application Development. You build it one step a week from week 3 to week 15, in this repo. This week is step 5: the entries move into one object, the notifier, that every screen listens to. You can then edit and delete an entry, and every screen shows the change. The code is split into three folders: `data`, `logic` and `ui`.

This project needs Flutter 3.50.0 or newer.

## Get this week's files

Choose one of the two paths. The handout explains both, step by step.

**Continue.** You already have a `roznamcha` repo, and its week 6 tests pass. Commit your work first. Then open a terminal in your repo's folder and run these commands, one at a time:

```bash
git remote add week7 https://github.com/hackingwithflutter/mad-07-roznamcha-notifier.git
git fetch week7
git rm -r -q lib test/add_entry_screen_test.dart
git checkout week7/main -- .
```

The third command is new this week. Every file in `lib` moved into a folder, so last week's `lib` goes first, and the template brings every file back in its new place. One test file goes too, because its screen has a new name. Files that only you have stay: `screenshot.png`, your `AI_LOG.md`, and your own test, `test/my_weather_test.dart`. Your own test needs one change before you commit: the handout shows it.

**Restart.** You have no working `roznamcha` repo. Make a new `roznamcha` repo from this template, as the handout says.

## How to run

1. Connect your Android phone to your laptop with a USB cable. USB debugging must be on.
2. Open a terminal in this folder and run these two commands:

   ```bash
   flutter pub get
   flutter run
   ```

There is no new package this week. The untouched starter goes from the welcome screen to the name form to the home screen, and the home screen looks as it did in week 6. A tap on an entry opens a screen that says `This entry is not in your diary.`: the home screen still shows its own copy of the entries, and the notifier has none yet. TODO 1 and TODO 5 fix that.

## Where the code is

```text
lib/
  main.dart     makes the objects the whole app shares, and starts the app
  data/         what an entry is, and where entries and the weather come from
  logic/        the notifier that holds the entries; searching and sorting
  ui/           the screens and the widgets
```

A file in `ui` may import from `logic` and `data`. A file in `logic` may import from `data`. A file in `data` imports from neither. `test/layers_test.dart` checks this.

## Your tasks

Read these files first, in this order; the comments explain the given code: `lib/data/entry.dart`, `lib/data/entry_repository.dart`, `lib/logic/entries_notifier.dart`, `lib/main.dart`, `lib/ui/app_flow.dart`, `lib/ui/screens/entry_detail_screen.dart`, `lib/ui/screens/home_screen.dart` and `lib/ui/screens/entry_form_screen.dart`. Then do TODO 1, 2, 3 and 4 in `entries_notifier.dart`, TODO 5 in `home_screen.dart` and TODO 6 in `entry_form_screen.dart`. The handout explains each, and shows the design.

## Tests

Run the tests with this command:

```bash
flutter test
```

There are 106 tests in fifteen files. On the untouched starter, 84 pass and 22 fail. The 84 that pass check given code, most of the screens of weeks 3 to 6 among it. The failing tests are expected. No test uses the internet. GitHub Actions runs the same tests on every push, so it shows a red cross until you finish. When all six TODOs are done, the last line says `+106: All tests passed!`. If you kept your own test file from week 6, your numbers are higher by the number of tests in it.

## My screenshot

![The detail screen of an entry I edited, on my phone](screenshot.png)

Replace this picture with your own. Edit an entry on your phone, take a screenshot of its detail screen, name it `screenshot.png`, and put it in the top folder of this repository, next to this README.

## AI log

You keep a log of how you used AI in the file `AI_LOG.md`, next to this README (AI Level 2). This template has no `AI_LOG.md`, so that it can't replace yours. On the continue path, your log stays. The handout gives the heading to add for week 7, and the text of the whole file if you start a new one.

## Thanks

The weather comes from Open-Meteo (https://open-meteo.com/), which is free for apps like this one and needs no key. The app names it next to the temperature, as its licence asks.

## Next weeks

Keep this repo. Each handout tells you how to add that week's starter files to it.
