//
//  NotificationService.swift
//  TapFrenzy
//
//  Created by Seyyed Omar on 2026-07-10.
//

import Foundation
import UserNotifications

struct NotificationService {
    static let shared = NotificationService()

    private let dailyChallengeID = "dailyChallenge"

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// Schedules a daily repeating reminder at the given hour/minute.
    func scheduleDailyChallenge(hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyChallengeID])

        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Your PlayHub challenge is ready — jump in and beat your best score!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyChallengeID, content: content, trigger: trigger)
        center.add(request)
    }

    func cancelDailyChallenge() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyChallengeID])
    }
}


