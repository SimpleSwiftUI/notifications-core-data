//
//  NotificationsView.swift
//  notifications-core-data
//
//  Created by Robert Brennan on 2/25/24.
//

import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var selectedTime: Date?
    @State private var notificationType = "Daily" // or "Weekly"
    @State private var selectedDayOfWeek = 1 // Sunday = 1, Monday = 2, ..., Saturday = 7
    @State private var notificationBody = "My notification content."
    @State private var hasNotificationPermission = false
    
    @State private var permissionRequested = false
    @State private var permissionDenied = false
    @State private var showWeeklyControls = false
    
    @FocusState private var isLabelInputActive: Bool
    
    var body: some View {
        VStack {
            Text("Notifications")
                .padding(.vertical, 3)
                .font(.title)

            Text("Set daily/weekly notifications.")
                .multilineTextAlignment(.center)
                .font(.caption)
                .padding()
            
            if !hasNotificationPermission {
                Text("Notification permissions are required to set notifications.")
                    .multilineTextAlignment(.center)
                    .font(.caption)
                    .padding()
                
                if !permissionRequested {
                    Button {
                        viewModel.requestNotificationAuthorization { granted in
                            hasNotificationPermission = granted
                            permissionRequested = true
                            permissionDenied = !granted
                        }
                    } label: {
                        Text("Request Permission")
                            .font(.footnote)
                    }
                    .padding()
                } else if permissionDenied {
                    Button {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                              UIApplication.shared.canOpenURL(settingsUrl) else {
                            return
                        }
                        UIApplication.shared.open(settingsUrl)
                    } label: {
                        Text("Open Settings")
                            .font(.footnote)
                    }
                    .padding()
                }
                Spacer()
            } else {    // notification permissions are granted
                VStack {
                    Picker("Notification Type", selection: $notificationType) {
                        Text("Daily").tag("Daily")
                        Text("Weekly").tag("Weekly")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 36)
                    // .onChange(of: notificationType) { newType in             // iOS 16
                    .onChange(of: notificationType) { currentType, newType in   // iOS 17
                        withAnimation {
                            showWeeklyControls = (newType == "Weekly")
                        }
                    }

                    if showWeeklyControls {
                        HStack {
                            Text("Day:")
                                .font(.body)
                            
                            Spacer()
                            
                            Picker("Day of Week", selection: $selectedDayOfWeek) {
                                ForEach(1..<8, id: \.self) { day in
                                    Text(Calendar.current.weekdaySymbols[day - 1]).tag(day)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.vertical, 3)
                        .padding(.horizontal, 36)
                        .transition(.opacity)
                    }
                    
                    DatePicker(
                        "Time:",
                        selection: Binding(
                            get: { self.selectedTime ?? Date() },
                            set: { self.selectedTime = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.compact)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 36)
                    
                    HStack {
                        Text("Label:")
                        
                        TextField("Notification content", text: $notificationBody)
                            .focused($isLabelInputActive)
                            .font(.subheadline)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 6)
                            .cornerRadius(5)
                            // .onChange(of: notificationBody) { newValue in                // iOS 16
                            .onChange(of: notificationBody) { currentValue, newValue in     // iOS 17
                                if notificationBody.count > 60 {
                                    notificationBody = String(notificationBody.prefix(40))
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 5) // Use RoundedRectangle for border
                                    .stroke(.secondary, lineWidth: 1) // Set border color and line width
                            )
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 36)
                                           
                    Button("Set Notification") {
                        let timeToSet = selectedTime ?? Date()
                        let finalNotificationBody = notificationBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? "My notification content."
                            : notificationBody
                        viewModel.setNotification(time: timeToSet, type: notificationType, dayOfWeek: (notificationType == "Weekly" ? selectedDayOfWeek : nil), body: finalNotificationBody)
                    }
                    .disabled(!hasNotificationPermission)
                    .padding(.top, 6)
                    .padding(.bottom, 21)
                    
                    Divider()
                        .padding(.horizontal, 36)
                    
                    Text("Current Notifications")
                        .font(.headline)
                        .padding(.top, 9)
                        .padding(.bottom, 2)
                    
                    if viewModel.existingNotifications.count == 0 {
                        Text("No notifications set.")
                            .font(.footnote)
                            .italic()
                            .padding()
                    } else {
                        List {
                            ForEach(viewModel.existingNotifications, id: \.self) { notification in
                                HStack {
                                    if notification.type == "Daily" {
                                        Text("DAILY")
                                            .font(.caption.bold())
                                            .frame(width: 88)
                                    } else {
                                        Text("\(getDayOfWeek(notification.dayOfWeek).uppercased())")
                                            .font(.caption.bold())
                                            .frame(width: 88)
                                    }
                                           
                                    Text("\(notification.time ?? Date(), formatter: itemFormatter)")
                                        .font(.caption)
                                        .frame(width: 66)
                                    
                                    Text("\(notification.body ?? "")")
                                        .font(.caption)
                                    
                                }
                            }
                            .onDelete(perform: { offsets in
                                Task {
                                    viewModel.deleteNotifications(at: offsets)
                                }
                            })
                            .listRowSeparator(.hidden)
                        }
                        .listStyle(.plain)
                        
                        Text("Swipe left to delete.")
                            .font(.caption2)
                            .italic()
                            .foregroundColor(.secondary)
                            .padding(.bottom, 6)
                    }
                    
                    
                    Spacer()
                    
                }
            }
        }
        .onAppear {
            viewModel.checkNotificationPermission { granted, denied in
                hasNotificationPermission = granted
                permissionRequested = granted || denied
                permissionDenied = denied
                if granted {
                    viewModel.existingNotifications = viewModel.fetchAllNotifications()
                }
            }
        }
    }
    
    private var itemFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    private func getDayOfWeek(_ dayNumber: Int16?) -> String {
        guard let dayNumber = dayNumber, dayNumber > 0, dayNumber <= 7 else {
            return "Unknown"
        }
        return Calendar.current.weekdaySymbols[Int(dayNumber) - 1]
    }
}

//#Pr
