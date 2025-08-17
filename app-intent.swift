//
//  app-intent.swift
//  ANIS
//
//  Created by shoog on 22/02/1447 AH.
//
import Foundation
import AppIntents
import SwiftUI

// MARK: - App Intents

struct FindActivitiesIntent: AppIntent {
    static var title: LocalizedStringResource = "Find Activities"
    static var description = IntentDescription("Find sports activities near you")

    @Parameter(title: "Search Radius", default: 10.0)
    var searchRadius: Double
    
    @Parameter(title: "Sport Type")
    var sportType: String?

    func perform() async throws -> some IntentResult & ReturnsValue<[ActivityIntentResult]> {
        let mockService = MockDataService.shared
        let activities = mockService.findActivities(radius: searchRadius, sportType: sportType)
        
        let intentResults = activities.map { activity in
            ActivityIntentResult(
                id: activity.id,
                title: activity.title,
                sportType: activity.sportType,
                dateTime: activity.dateTime,
                location: activity.location,
                availableSlots: activity.availableSlots
            )
        }
        
        return .result(value: intentResults)
    }
}

struct JoinActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Join Activity"
    static var description = IntentDescription("Join a sports activity")

    @Parameter(title: "Activity ID")
    var activityId: String

    func perform() async throws -> some IntentResult & ReturnsValue<JoinResult> {
        let mockService = MockDataService.shared
        let joinResult = mockService.joinActivity(activityId: activityId)
        
        let result = JoinResult(
            success: joinResult.success,
            message: joinResult.message,
            activityTitle: joinResult.activity?.title ?? "Unknown Activity"
        )
        
        return .result(value: result)
    }
}

struct CreateActivityIntent: AppIntent {
    static var title: LocalizedStringResource = "Create Activity"
    static var description = IntentDescription("Create a new sports activity")

    @Parameter(title: "Title")
    var title: String

    @Parameter(title: "Sport Type")
    var sportType: String

    @Parameter(title: "Date and Time")
    var dateTime: Date

    @Parameter(title: "Max Participants", default: 10)
    var maxParticipants: Int

    @Parameter(title: "Description")
    var description: String?
    
    @Parameter(title: "Location")
    var location: String?

    func perform() async throws -> some IntentResult & ReturnsValue<CreateActivityResult> {
        let mockService = MockDataService.shared
        
        let newActivity = mockService.createActivity(
            title: title,
            description: description,
            sportType: sportType,
            dateTime: dateTime,
            location: location ?? "TBD",
            maxParticipants: maxParticipants
        )
        
        let result = CreateActivityResult(
            success: true,
            message: "Activity '\(newActivity.title)' created successfully!",
            activityId: newActivity.id
        )
        
        return .result(value: result)
    }
}

struct GetUserProfileIntent: AppIntent {
    static var title: LocalizedStringResource = "Get User Profile"
    static var description = IntentDescription("Get information about the current user")

    func perform() async throws -> some IntentResult & ReturnsValue<UserProfileResult> {
        let mockService = MockDataService.shared
        
        guard let currentUser = mockService.getCurrentUser() else {
            throw AppIntentError.userNotFound
        }
        
        let upcomingActivities = mockService.getUpcomingActivities()
        
        let result = UserProfileResult(
            name: currentUser.name,
            interests: currentUser.interests,
            upcomingActivities: upcomingActivities.count,
            totalActivities: currentUser.totalActivities
        )
        
        return .result(value: result)
    }
}

struct GetUpcomingActivitiesIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Upcoming Activities"
    static var description = IntentDescription("Get your upcoming sports activities")

    func perform() async throws -> some IntentResult & ReturnsValue<[ActivityIntentResult]> {
        let mockService = MockDataService.shared
        let upcomingActivities = mockService.getUpcomingActivities()
        
        let intentResults = upcomingActivities.map { activity in
            ActivityIntentResult(
                id: activity.id,
                title: activity.title,
                sportType: activity.sportType,
                dateTime: activity.dateTime,
                location: activity.location,
                availableSlots: activity.availableSlots
            )
        }
        
        return .result(value: intentResults)
    }
}

// MARK: - AppEntities

struct ActivityIntentResult: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Activity")
    static var defaultQuery = ActivityIntentQuery()
    
    typealias ID = String
    var id: ID

    let title: String
    let sportType: String
    let dateTime: Date
    let location: String
    let availableSlots: Int

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: title),
            subtitle: LocalizedStringResource(stringLiteral: "\(sportType) • \(dateTime.formatted(date: .abbreviated, time: .shortened)) • \(location)")
        )
    }
}

struct JoinResult: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Join Result")
    static var defaultQuery = JoinResultQuery()
    typealias ID = String
    var id: ID { message }

    let success: Bool
    let message: String
    let activityTitle: String

    var displayRepresentation: DisplayRepresentation {
        let emoji = success ? "✅" : "❌"
        return DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: "\(emoji) \(message)"),
            subtitle: LocalizedStringResource(stringLiteral: activityTitle)
        )
    }
}

struct CreateActivityResult: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Create Activity Result")
    static var defaultQuery = CreateActivityResultQuery()
    typealias ID = String
    var id: ID { activityId }

    let success: Bool
    let message: String
    let activityId: String

    var displayRepresentation: DisplayRepresentation {
        return DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: "✅ \(message)"),
            subtitle: LocalizedStringResource(stringLiteral: "Activity ID: \(activityId)")
        )
    }
}

struct UserProfileResult: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "User Profile")
    static var defaultQuery = UserProfileResultQuery()
    typealias ID = String
    var id: ID { name }

    let name: String
    let interests: [String]
    let upcomingActivities: Int
    let totalActivities: Int

    var displayRepresentation: DisplayRepresentation {
        let interestsString = interests.joined(separator: ", ")
        return DisplayRepresentation(
            title: LocalizedStringResource(stringLiteral: "👤 \(name)"),
            subtitle: LocalizedStringResource(stringLiteral: "Interests: \(interestsString) • \(upcomingActivities) upcoming • \(totalActivities) total")
        )
    }
}

// MARK: - Entity Queries

struct ActivityIntentQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [ActivityIntentResult] {
        let mockService = MockDataService.shared
        let activities = identifiers.compactMap { id in
            mockService.getActivity(by: id)
        }
        
        return activities.map { activity in
            ActivityIntentResult(
                id: activity.id,
                title: activity.title,
                sportType: activity.sportType,
                dateTime: activity.dateTime,
                location: activity.location,
                availableSlots: activity.availableSlots
            )
        }
    }
    
    func suggestedEntities() async throws -> [ActivityIntentResult] {
        let mockService = MockDataService.shared
        let activities = mockService.findActivities().prefix(5)
        
        return activities.map { activity in
            ActivityIntentResult(
                id: activity.id,
                title: activity.title,
                sportType: activity.sportType,
                dateTime: activity.dateTime,
                location: activity.location,
                availableSlots: activity.availableSlots
            )
        }
    }
}

struct JoinResultQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [JoinResult] { [] }
    func suggestedEntities() async throws -> [JoinResult] { [] }
}

struct CreateActivityResultQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [CreateActivityResult] { [] }
    func suggestedEntities() async throws -> [CreateActivityResult] { [] }
}

struct UserProfileResultQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [UserProfileResult] { [] }
    func suggestedEntities() async throws -> [UserProfileResult] { [] }
}

// MARK: - App Shortcuts

struct ANISAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [
            AppShortcut(
                intent: FindActivitiesIntent(),
                phrases: [
                    "Find activities in \(.applicationName)",
                    "Show me sports activities in \(.applicationName)",
                    "Search for activities near me in \(.applicationName)"
                ],
                shortTitle: "Find Activities",
                systemImageName: "sportscourt"
            ),
            AppShortcut(
                intent: JoinActivityIntent(),
                phrases: [
                    "Join activity in \(.applicationName)",
                    "Sign me up for an activity in \(.applicationName)",
                    "Register for sports activity in \(.applicationName)"
                ],
                shortTitle: "Join Activity",
                systemImageName: "person.badge.plus"
            ),
            AppShortcut(
                intent: CreateActivityIntent(),
                phrases: [
                    "Create activity in \(.applicationName)",
                    "Start a new sports session in \(.applicationName)",
                    "Organize sports activity in \(.applicationName)"
                ],
                shortTitle: "Create Activity",
                systemImageName: "plus.circle"
            ),
            AppShortcut(
                intent: GetUserProfileIntent(),
                phrases: [
                    "Show my profile in \(.applicationName)",
                    "What's my profile in \(.applicationName)",
                    "My sports profile in \(.applicationName)"
                ],
                shortTitle: "My Profile",
                systemImageName: "person.circle"
            ),
            AppShortcut(
                intent: GetUpcomingActivitiesIntent(),
                phrases: [
                    "Show my upcoming activities in \(.applicationName)",
                    "What activities do I have coming up in \(.applicationName)",
                    "My sports schedule in \(.applicationName)"
                ],
                shortTitle: "Upcoming Activities",
                systemImageName: "calendar"
            )
        ]
    }
}

// MARK: - Error Handling

enum AppIntentError: Swift.Error, LocalizedError {
    case userNotFound
    case activityNotFound
    case joinFailed(String)
    case createFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found. Please make sure you're logged in."
        case .activityNotFound:
            return "Activity not found. It may have been cancelled or removed."
        case .joinFailed(let message):
            return "Failed to join activity: \(message)"
        case .createFailed(let message):
            return "Failed to create activity: \(message)"
        }
    }
}