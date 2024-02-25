//
//  ViewModel.swift
//  notifications-core-data
//
//  Created by Robert Brennan on 2/25/24.
//

import Foundation
import CoreData
import UserNotifications

class ViewModel: ObservableObject {
    private var managedObjectContext: NSManagedObjectContext
    
    @Published var existingNotifications: [NotificationItem] = []
    
    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
        self.existingNotifications = fetchAllNotifications()
    }
    
    func fetchAllNotifications() -> [NotificationItem] {
        let request: NSFetchRequest<NotificationItem> = NotificationItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NotificationItem.time, ascending: true)]
        do {
            let ret = try managedObjectContext.fetch(request)
            // print("fetchAllNotifications ret:", ret)
            return ret
        } catch {
            print("fetchAllNotifications error: \(error)")
            return []
        }
    }
    
    func scheduleNotification(time: Date, type: String, dayOfWeek: Int?, body: String, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "My Notification Title"
        content.body = body
        content.sound = UNNotificationSound.default
        
        var dateComponents = Calendar.current.dateComponents([.hour, .minute], from: time)
        if type == "Weekly", let dayOfWeek = dayOfWeek {
            dateComponents.weekday = dayOfWeek
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("scheduleNotification error: \(error)")
            }
        }
    }
    
    func setNotification(time: Date, type: String, dayOfWeek: Int?, body: String = "My notification content.") {
        let newNotification = NotificationItem(context: self.managedObjectContext)
        newNotification.time = time
        newNotification.type = type
        newNotification.dayOfWeek = Int16(dayOfWeek ?? 1)
        newNotification.body = body
        
        let notificationIdentifier = UUID().uuidString
        newNotification.notificationID = notificationIdentifier
        
        do {
            try self.managedObjectContext.save()
            print("Notification saved")
            self.scheduleNotification(time: time, type: type, dayOfWeek: dayOfWeek, body: body, identifier: notificationIdentifier)
            self.existingNotifications = fetchAllNotifications()
        } catch {
            print("setNotification error: \(error)")
        }
    }
    
    @MainActor
    func deleteNotifications(at offsets: IndexSet) {
        for index in offsets {
            let notification = existingNotifications[index]
            deleteNotification(notification)
        }
    }
    
    func deleteNotification(_ notification: NotificationItem) {
        if let notificationId = notification.notificationID {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationId])
            print("Notification deleted")
        }
                
        managedObjectContext.delete(notification)
        do {
            try managedObjectContext.save()
            self.existingNotifications = fetchAllNotifications()
            // print("Notification deleted")
        } catch {
            print("deleteNotification error: \(error)")
        }
    }
    
    func checkNotificationPermission(completion: @escaping (Bool, Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                let isDenied = settings.authorizationStatus == .denied
                completion(isAuthorized, isDenied)
            }
        }
    }
    
    func requestNotificationAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification permission denied because: \(error)")
                }
                completion(granted)
            }
        }
    }
}
