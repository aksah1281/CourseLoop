//
//  AuthViewModel.swift
//  CourseLoop
//
//  Created by Akash Patel on 5/13/25.
//

import SwiftUI
import Supabase

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var currentProfile: UserModel?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let supabase = SupabaseManager.shared
    
    init() {
        // Check if user is already signed in
        checkSession()
    }
    
    func checkSession() {
        Task {
            do {
                isLoading = true
                let session = try await supabase.getSession()
                
                if let user = session?.user {
                    // Fetch user profile
                    let profile = try await supabase.getUserProfile(userId: user.id)
                    
                    DispatchQueue.main.async {
                        self.currentUser = user
                        self.currentProfile = profile
                        self.isLoading = false
                    }
                } else {
                    DispatchQueue.main.async {
                        self.currentUser = nil
                        self.currentProfile = nil
                        self.isLoading = false
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                    self.currentUser = nil
                    self.currentProfile = nil
                    self.isLoading = false
                }
            }
        }
    }
    
    func signOut() {
        Task {
            do {
                isLoading = true
                try await supabase.signOut()
                
                DispatchQueue.main.async {
                    self.currentUser = nil
                    self.currentProfile = nil
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    func sendOTPForLogin(email: String) {
        // Check if email has .edu domain
        if !email.lowercased().hasSuffix(".edu") {
            DispatchQueue.main.async {
                self.errorMessage = "Please use your university email address (.edu)"
                self.showError = true
            }
            return
        }
        
        Task {
            do {
                isLoading = true
                
                // Send OTP to email
                try await supabase.signInWithOTP(email: email)
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = nil
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    func verifyOTP(email: String, token: String, completion: @escaping (Bool) -> Void) {
        Task {
            do {
                isLoading = true
                
                if let user = try await supabase.verifyOTP(email: email, token: token) {
                    // Fetch user profile
                    do {
                        let profile = try await supabase.getUserProfile(userId: user.id)
                        DispatchQueue.main.async {
                            self.currentUser = user
                            self.currentProfile = profile
                            self.isLoading = false
                            completion(true)
                        }
                    } catch {
                        // If profile doesn't exist (new user), we'll create it later when setting username
                        DispatchQueue.main.async {
                            self.currentUser = user
                            self.isLoading = false
                            completion(true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Invalid verification code"
                        self.showError = true
                        self.isLoading = false
                        completion(false)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                    self.isLoading = false
                    completion(false)
                }
            }
        }
    }
    
    func setUsername(username: String) {
        guard let userId = currentUser?.id else { return }
        
        Task {
            do {
                isLoading = true
                
                try await supabase.updateUserProfile(
                    userId: userId,
                    data: ["username": username]
                )
                
                // Fetch updated profile
                let profile = try await supabase.getUserProfile(userId: userId)
                
                DispatchQueue.main.async {
                    self.currentProfile = profile
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    func addUserCourses(currentCourses: [CourseEntry], previousCourses: [CourseEntry]) {
        guard let userId = currentUser?.id else { return }
        
        Task {
            do {
                isLoading = true
                
                // Process current courses
                for course in currentCourses {
                    // First, check if course exists
                    let courseResponse = try await supabase.client
                        .from("courses")
                        .select()
                        .eq("course_code", value: course.courseCode)
                        .eq("professor_name", value: course.professorName)
                        .execute()
                    
                    let courses = try JSONDecoder().decode([CourseModel].self, from: courseResponse.data)
                    
                    var courseId: String
                    
                    if let existingCourse = courses.first {
                        courseId = existingCourse.id
                    } else {
                        // Create the course
                        let newCourse = [
                            "course_code": course.courseCode,
                            "professor_name": course.professorName
                        ]
                        
                        let insertResponse = try await supabase.client
                            .from("courses")
                            .insert(newCourse)
                            .single()
                            .execute()
                        
                        let createdCourse = try JSONDecoder().decode(CourseModel.self, from: insertResponse.data)
                        courseId = createdCourse.id
                    }
                    
                    // Add course to user's courses
                    try await supabase.addUserCourse(userId: userId, courseId: courseId)
                }
                
                // Process previous courses (similar to current courses)
                for course in previousCourses {
                    let courseResponse = try await supabase.client
                        .from("courses")
                        .select()
                        .eq("course_code", value: course.courseCode)
                        .eq("professor_name", value: course.professorName)
                        .execute()
                    
                    let courses = try JSONDecoder().decode([CourseModel].self, from: courseResponse.data)
                    
                    var courseId: String
                    
                    if let existingCourse = courses.first {
                        courseId = existingCourse.id
                    } else {
                        let newCourse = [
                            "course_code": course.courseCode,
                            "professor_name": course.professorName
                        ]
                        
                        let insertResponse = try await supabase.client
                            .from("courses")
                            .insert(newCourse)
                            .single()
                            .execute()
                        
                        let createdCourse = try JSONDecoder().decode(CourseModel.self, from: insertResponse.data)
                        courseId = createdCourse.id
                    }
                    
                    try await supabase.addUserCourse(userId: userId, courseId: courseId)
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.handleError(error)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func handleError(_ error: Error) {
        // Parse error and set appropriate message
        errorMessage = "Error: \(error.localizedDescription)"
        showError = true
    }
}

// MARK: - Supabase Auth Provider
struct SupabaseAuthProvider: ViewModifier {
    @StateObject var authViewModel = AuthViewModel()
    
    func body(content: Content) -> some View {
        content
            .environmentObject(authViewModel)
    }
}

extension View {
    func withSupabaseAuth() -> some View {
        modifier(SupabaseAuthProvider())
    }
}