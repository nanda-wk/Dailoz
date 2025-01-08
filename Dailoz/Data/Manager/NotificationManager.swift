//
//  NotificationManager.swift
//  Dailoz
//
//  Created by Nanda WK on 2025-01-08.
//

import CoreData
import Foundation
import UserNotifications

func scheduleNotification(for task: TaskEntity) {
    let preferences = UserPreferences()

    guard preferences.allowNotification else {
        return
    }

    let notificationCenter = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = task.title
    content.body = task.tDescription
    content.sound = .default

    let now = Date()
    let startTime = task.startTime.convertedToCurrentTimeZone()
    guard startTime > now else {
        return
    }

//    let timeInterval = task.startTime.timeIntervalSince(now)
//    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

    let calendar = Calendar.current

    // Extract date components (year, month, day) from `date`
    let dateComponents = calendar.dateComponents([.year, .month, .day], from: task.date)

    // Extract time components (hour, minute) from `startTime`
    let timeComponents = calendar.dateComponents([.hour, .minute], from: task.startTime)

    // Combine them into a single `Date`
    var combinedComponents = DateComponents()
    combinedComponents.year = dateComponents.year
    combinedComponents.month = dateComponents.month
    combinedComponents.day = dateComponents.day
    combinedComponents.hour = timeComponents.hour
    combinedComponents.minute = timeComponents.minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: combinedComponents, repeats: false)

    let request = UNNotificationRequest(identifier: task.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)

    notificationCenter.add(request) { error in
        if let error {
            print("Error scheduling notification for task: \(error.localizedDescription)")
        } else {
            print("Notification scheduled for task: \(task.title) at \(task.startTime)")
        }
    }
}

func scheduleNotificationsForAllTasks(context: NSManagedObjectContext) {
    let fetchRequest = TaskEntity.all()

    do {
        let tasks = try context.fetch(fetchRequest)
        for task in tasks {
            scheduleNotification(for: task)
        }
    } catch {
        print("Failed to fetch tasks: \(error.localizedDescription)")
    }
}

func updateNotification(for task: TaskEntity) {
    let notificationCenter = UNUserNotificationCenter.current()
    let identifier = task.objectID.uriRepresentation().absoluteString

    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    scheduleNotification(for: task)
}

func removeNotification(for task: TaskEntity) {
    let notificationCenter = UNUserNotificationCenter.current()
    let identifier = task.objectID.uriRepresentation().absoluteString

    notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
}

func disableAllNotifications() {
    let notificationCenter = UNUserNotificationCenter.current()
    notificationCenter.removeAllPendingNotificationRequests()
    notificationCenter.removeAllDeliveredNotifications()
}
