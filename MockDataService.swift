//
//  MockDataService.swift
//  ANIS
//
//  Created by Assistant
//

import Foundation

// MARK: - Data Models

struct Activity: Identifiable, Codable {
    let id: String
    let title: String
    let description: String?
    let sportType: String
    let dateTime: Date
    let location: String
    let maxParticipants: Int
    let currentParticipants: Int
    let creatorId: String
    let participantIds: [String]
    
    var availableSlots: Int {
        return maxParticipants - currentParticipants
    }
    
    var isAvailable: Bool {
        return availableSlots > 0
    }
}

struct User: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let interests: [String]
    let profileImageURL: String?
    let createdActivities: [String] // Activity IDs
    let joinedActivities: [String] // Activity IDs
    
    var totalActivities: Int {
        return createdActivities.count + joinedActivities.count
    }
}

// MARK: - Mock Data Service

class MockDataService: ObservableObject {
    static let shared = MockDataService()
    
    @Published var activities: [Activity] = []
    @Published var users: [User] = []
    @Published var currentUser: User?
    
    private init() {
        loadMockData()
    }
    
    // MARK: - Mock Data Loading
    
    private func loadMockData() {
        // Mock Users
        users = [
            User(
                id: "user1",
                name: "John Doe",
                email: "john@example.com",
                interests: ["Padel", "Football", "Tennis"],
                profileImageURL: nil,
                createdActivities: ["1", "3"],
                joinedActivities: ["2"]
            ),
            User(
                id: "user2",
                name: "Sarah Smith",
                email: "sarah@example.com",
                interests: ["Basketball", "Padel", "Swimming"],
                profileImageURL: nil,
                createdActivities: ["2"],
                joinedActivities: ["1"]
            ),
            User(
                id: "user3",
                name: "Ahmed Al-Rashid",
                email: "ahmed@example.com",
                interests: ["Football", "Tennis", "Running"],
                profileImageURL: nil,
                createdActivities: ["4"],
                joinedActivities: ["1", "3"]
            )
        ]
        
        // Set current user
        currentUser = users.first
        
        // Mock Activities
        activities = [
            Activity(
                id: "1",
                title: "Morning Padel Session",
                description: "Join us for an exciting padel match at the sports complex. All skill levels welcome!",
                sportType: "Padel",
                dateTime: Date().addingTimeInterval(3600), // 1 hour from now
                location: "Sports Complex - Court 1",
                maxParticipants: 4,
                currentParticipants: 2,
                creatorId: "user1",
                participantIds: ["user1", "user2"]
            ),
            Activity(
                id: "2",
                title: "Football Training Session",
                description: "Weekly football training session. Focus on passing and shooting drills.",
                sportType: "Football",
                dateTime: Date().addingTimeInterval(7200), // 2 hours from now
                location: "Central Park - Field A",
                maxParticipants: 22,
                currentParticipants: 18,
                creatorId: "user2",
                participantIds: ["user2", "user1"] + (3...18).map { "participant\($0)" }
            ),
            Activity(
                id: "3",
                title: "Evening Tennis Match",
                description: "Friendly tennis doubles match. Intermediate level players preferred.",
                sportType: "Tennis",
                dateTime: Date().addingTimeInterval(14400), // 4 hours from now
                location: "Tennis Club - Court 3",
                maxParticipants: 4,
                currentParticipants: 3,
                creatorId: "user1",
                participantIds: ["user1", "user3", "participant19"]
            ),
            Activity(
                id: "4",
                title: "Basketball Pickup Game",
                description: "Casual basketball game. Come ready to play!",
                sportType: "Basketball",
                dateTime: Date().addingTimeInterval(21600), // 6 hours from now
                location: "Community Center - Indoor Court",
                maxParticipants: 10,
                currentParticipants: 7,
                creatorId: "user3",
                participantIds: ["user3"] + (20...25).map { "participant\($0)" }
            ),
            Activity(
                id: "5",
                title: "Swimming Workout",
                description: "Structured swimming workout with coach guidance.",
                sportType: "Swimming",
                dateTime: Date().addingTimeInterval(28800), // 8 hours from now
                location: "Aquatic Center - Pool 2",
                maxParticipants: 15,
                currentParticipants: 8,
                creatorId: "user2",
                participantIds: ["user2"] + (26...32).map { "participant\($0)" }
            )
        ]
    }
    
    // MARK: - Activity Methods
    
    func findActivities(radius: Double = 10.0, sportType: String? = nil) -> [Activity] {
        var filteredActivities = activities.filter { $0.dateTime > Date() }
        
        if let sportType = sportType {
            filteredActivities = filteredActivities.filter { $0.sportType.lowercased() == sportType.lowercased() }
        }
        
        return filteredActivities.sorted { $0.dateTime < $1.dateTime }
    }
    
    func getActivity(by id: String) -> Activity? {
        return activities.first { $0.id == id }
    }
    
    func createActivity(
        title: String,
        description: String?,
        sportType: String,
        dateTime: Date,
        location: String = "TBD",
        maxParticipants: Int
    ) -> Activity {
        let newActivity = Activity(
            id: UUID().uuidString,
            title: title,
            description: description,
            sportType: sportType,
            dateTime: dateTime,
            location: location,
            maxParticipants: maxParticipants,
            currentParticipants: 1,
            creatorId: currentUser?.id ?? "unknown",
            participantIds: [currentUser?.id ?? "unknown"]
        )
        
        activities.append(newActivity)
        
        // Update current user's created activities
        if let currentUser = currentUser,
           let userIndex = users.firstIndex(where: { $0.id == currentUser.id }) {
            var updatedUser = users[userIndex]
            updatedUser = User(
                id: updatedUser.id,
                name: updatedUser.name,
                email: updatedUser.email,
                interests: updatedUser.interests,
                profileImageURL: updatedUser.profileImageURL,
                createdActivities: updatedUser.createdActivities + [newActivity.id],
                joinedActivities: updatedUser.joinedActivities
            )
            users[userIndex] = updatedUser
            self.currentUser = updatedUser
        }
        
        return newActivity
    }
    
    func joinActivity(activityId: String, userId: String? = nil) -> (success: Bool, message: String, activity: Activity?) {
        let userIdToUse = userId ?? currentUser?.id ?? "unknown"
        
        guard let activityIndex = activities.firstIndex(where: { $0.id == activityId }) else {
            return (false, "Activity not found", nil)
        }
        
        var activity = activities[activityIndex]
        
        if activity.participantIds.contains(userIdToUse) {
            return (false, "You are already registered for this activity", activity)
        }
        
        if !activity.isAvailable {
            return (false, "Activity is full", activity)
        }
        
        // Update activity
        let updatedActivity = Activity(
            id: activity.id,
            title: activity.title,
            description: activity.description,
            sportType: activity.sportType,
            dateTime: activity.dateTime,
            location: activity.location,
            maxParticipants: activity.maxParticipants,
            currentParticipants: activity.currentParticipants + 1,
            creatorId: activity.creatorId,
            participantIds: activity.participantIds + [userIdToUse]
        )
        
        activities[activityIndex] = updatedActivity
        
        // Update user's joined activities
        if let userIndex = users.firstIndex(where: { $0.id == userIdToUse }) {
            var updatedUser = users[userIndex]
            updatedUser = User(
                id: updatedUser.id,
                name: updatedUser.name,
                email: updatedUser.email,
                interests: updatedUser.interests,
                profileImageURL: updatedUser.profileImageURL,
                createdActivities: updatedUser.createdActivities,
                joinedActivities: updatedUser.joinedActivities + [activityId]
            )
            users[userIndex] = updatedUser
            
            if userIdToUse == currentUser?.id {
                self.currentUser = updatedUser
            }
        }
        
        return (true, "Successfully joined activity!", updatedActivity)
    }
    
    func getUpcomingActivities(for userId: String? = nil) -> [Activity] {
        let userIdToUse = userId ?? currentUser?.id ?? "unknown"
        
        return activities.filter { activity in
            activity.dateTime > Date() && 
            (activity.participantIds.contains(userIdToUse) || activity.creatorId == userIdToUse)
        }.sorted { $0.dateTime < $1.dateTime }
    }
    
    func getUserActivities(for userId: String? = nil) -> (created: [Activity], joined: [Activity]) {
        let userIdToUse = userId ?? currentUser?.id ?? "unknown"
        
        let createdActivities = activities.filter { $0.creatorId == userIdToUse }
        let joinedActivities = activities.filter { 
            $0.participantIds.contains(userIdToUse) && $0.creatorId != userIdToUse 
        }
        
        return (createdActivities, joinedActivities)
    }
    
    // MARK: - User Methods
    
    func getUser(by id: String) -> User? {
        return users.first { $0.id == id }
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func updateCurrentUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            currentUser = user
        }
    }
}