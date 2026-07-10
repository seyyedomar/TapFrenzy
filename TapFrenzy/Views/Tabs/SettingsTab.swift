//
//  SettingsTab.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-10.
//

import SwiftUI

struct SettingsTab: View {
    @AppStorage("dailyChallengeEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeHour") private var challengeHour = 18
    @AppStorage("dailyChallengeMinute") private var challengeMinute = 0
    @State private var showResetConfirmation = false

    private var challengeTime: Binding<Date> {
        Binding(
            get: {
                var components = DateComponents()
                components.hour = challengeHour
                components.minute = challengeMinute
                return Calendar.current.date(from: components) ?? Date()
            },
            set: { newDate in
                let components = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                challengeHour = components.hour ?? 18
                challengeMinute = components.minute ?? 0
                if notificationsEnabled {
                    NotificationService.shared.scheduleDailyChallenge(hour: challengeHour, minute: challengeMinute)
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Challenge") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled {
                                NotificationService.shared.requestPermission { granted in
                                    if granted {
                                        NotificationService.shared.scheduleDailyChallenge(
                                            hour: challengeHour,
                                            minute: challengeMinute
                                        )
                                    } else {
                                        notificationsEnabled = false
                                    }
                                }
                            } else {
                                NotificationService.shared.cancelDailyChallenge()
                            }
                        }

                    if notificationsEnabled {
                        DatePicker("Challenge Time", selection: challengeTime, displayedComponents: .hourAndMinute)
                    }
                }

                Section("Data") {
                    Button("Reset All Stats", role: .destructive) {
                        showResetConfirmation = true
                    }
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog(
                "Reset all stats?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset", role: .destructive) {
                    GameSessionStore.shared.resetAll()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This deletes every recorded game session. This can't be undone.")
            }
        }
    }
}

#Preview {
    SettingsTab()
}
