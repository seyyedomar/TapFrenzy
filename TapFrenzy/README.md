# PlayHub

A 3-game iOS app built over 4 weeks: Tap Frenzy, Light It Up, and Quiz
Rush, wrapped in a tab based shell with stats, a map of past games, daily
notifications, and score sharing.

## Architecture Overview

```
PlayHub/
  PlayHubApp.swift         — entry point, TabView shell (4 tabs)

  Models/
    GameMode.swift          — enum identifying the 3 games
    GameSession.swift       — one record per completed game + its
                              persisted store (GameSessionStore)
    TriviaQuestion.swift    — Codable model for Open Trivia DB

  ViewModels/
    TapFrenzyVM.swift       — Tap Frenzy's game state/logic
    LightItUpVM.swift       — Light It Up's game state/logic
    QuizRushVM.swift        — Quiz Rush's game state/logic + networking
    StatsVM.swift           — aggregates sessions for the Stats tab

  Services/
    TriviaAPI.swift         — async/await fetch from Open Trivia DB
    NotificationService.swift — wraps UNUserNotificationCenter
    LocationService.swift    — wraps CLLocationManager

  Views/
    Tabs/                   — HomeTab, StatsTab, MapTab, SettingsTab
    Games/                  — TapFrenzyView, LightItUpView, QuizRushView
    Shared/                 — ResultView (with ShareLink), ScoreBadge
```

**Why this structure:** each folder has one job Models describe data,
ViewModels hold game logic and state, Services talk to the outside world
(network, location, notifications), and Views only render what they're
given. None of the three games' Views contain scoring rules or timers
anymore  that all moved into their ViewModels in Week 4, which is what
makes them independently testable and readable on their own.

## Features

- **Tap Frenzy** — 10-second tap race with a combo multiplier and a
  shrinking button as time runs out.
- **Light It Up** — 60-second whack-a-mole round with 4 escalating
  difficulty levels (bigger grid, shorter lit window, more simultaneous
  lit cards).
- **Quiz Rush** — 10 live trivia questions from Open Trivia DB, streak
  bonus scoring, loading/error states with retry.
- **Stats tab** — total games played, total score, personal best per
  mode, a bar chart of recent scores (Swift Charts), and a recent-games
  list.
- **Map tab** — every completed game drops a pin at the location it was
  played; tapping a pin shows that session's mode, score, and date.
- **Daily Challenge notification** — enable in Settings, pick a time, and
  a repeating local notification fires daily at that time.
- **Share Your Score** — every result screen has a `ShareLink` that
  generates a one-line share message (e.g. "I just scored 47 on Quiz
  Rush — beat that!").
- **Settings** — notification toggle + time picker, and a
  reset-all-stats button behind a confirmation dialog.

## Known Limitations

- If location permission is denied, sessions still record with
  `(0, 0)` coordinates rather than being skipped — the Map tab will show
  pins clustered off the coast of Africa in that case. A cleaner version
  would omit the pin entirely when location isn't available.
- The daily notification body is static text — it doesn't reference the
  player's actual stats (e.g. "beat your Tap Frenzy record of 32").
- `TriviaQuestion.id` returns a new `UUID()` on every access rather than
  being stored, which works fine for `ForEach` in a single round but means
  identity isn't stable across relaunches — acceptable here since
  questions aren't persisted between rounds anyway.
- No unit tests yet — the ViewModel separation was done partly to make
  that possible later, but tests themselves aren't written.
- The Stats chart shows only the 10 most recent sessions, not full
  history, to keep the chart readable.

## Reflection

The biggest change this week wasn't a new feature — it was moving all
three games' logic out of their Views and into ViewModels. Doing that
first (before adding Stats/Map/Notifications) made every feature after it
easier, because the new features just needed to call into existing
ViewModels or read from `GameSessionStore` rather than reaching into view
state. The trickiest part was `LocationService` and `NotificationService`
both needing to run independent of any specific screen — making them
singletons (`.shared`) instead of view-owned objects was the right call
so a session recorded from any of the three games can pick up the same
current location without each game needing its own location manager.

