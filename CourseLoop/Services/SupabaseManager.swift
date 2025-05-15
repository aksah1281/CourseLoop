//
//  SupabaseManager.swift
//  CourseLoop
//
//  Created by Akash Patel on 5/13/25.
//
import Supabase
import Foundation

class SupabaseManager {
    static let shared = SupabaseManager()
    
    // Replace with your actual Supabase credentials
    private let supabaseURL = "https://pgzoxjnofwjthmatrxuv.supabase.co"
    private let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBnem94am5vZndqdGhtYXRyeHV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUxMDQ1NjgsImV4cCI6MjA2MDY4MDU2OH0.WrbqgMBO8RI6DlYMpXYhQeHtXuuHYBlqySe0hRZqgdk"
    
    private(set) lazy var client = SupabaseClient(
        supabaseURL: URL(string: supabaseURL)!,
        supabaseKey: supabaseKey
    )
    
    private init() {}
    
    // MARK: - Authentication Methods
    
    // Send OTP to user's email
    func signInWithOTP(email: String) async throws {
        try await client.auth.signInWithOTP(
            email: email,
            shouldCreateUser: true
        )
    }
    
    // Verify OTP code
    func verifyOTP(email: String, token: String) async throws -> User? {
        let authResponse = try await client.auth.verifyOTP(
            email: email,
            token: token,
            type: .email
        )
        
        return authResponse.user
    }
    
    // Get current session
    func getSession() async throws -> Session? {
        return try await client.auth.session
    }
    
    // Sign out
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // Get user profile
    func getUserProfile(userId: String) async throws -> UserModel {
        let response = try await client
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
        
        let data = try JSONDecoder().decode(UserModel.self, from: response.data)
        return data
    }
    
    // Update user profile
    func updateUserProfile(userId: String, data: [String: Any]) async throws {
        // Convert [String: Any] to Encodable data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let encodableData = try? JSONDecoder().decode([String: String].self, from: jsonData) else {
            throw NSError(domain: "Supabase", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])
        }
        
        try await client
            .from("profiles")
            .update(encodableData)
            .eq("id", value: userId)
            .execute()
    }
    
    // MARK: - Post Methods
    
    // Fetch all posts
    func fetchPosts() async throws -> [Post] {
        let response = try await client
            .from("posts")
            .select()
            .order("created_at", ascending: false)
            .execute()
        
        let data = try JSONDecoder().decode([PostModel].self, from: response.data)
        
        // Map from PostModel to Post
        return data.map { model in
            Post(
                id: model.id,
                text: model.content,
                timestamp: model.createdAt,
                username: model.username,
                courseCode: model.courseCode,
                likes: model.likes,
                comments: model.commentCount
            )
        }
    }
    
    // Create a new post
    func createPost(post: PostModel) async throws -> PostModel {
        let response = try await client
            .from("posts")
            .insert(post)
            .single()
            .execute()
        
        return try JSONDecoder().decode(PostModel.self, from: response.data)
    }
    
    // Fetch posts for a specific course
    func fetchPosts(forCourse courseCode: String) async throws -> [Post] {
        let response = try await client
            .from("posts")
            .select()
            .eq("course_code", value: courseCode)
            .order("created_at", ascending: false)
            .execute()
        
        let data = try JSONDecoder().decode([PostModel].self, from: response.data)
        
        return data.map { model in
            Post(
                id: model.id,
                text: model.content,
                timestamp: model.createdAt,
                username: model.username,
                courseCode: model.courseCode,
                likes: model.likes,
                comments: model.commentCount
            )
        }
    }
    
    // Like a post
    func likePost(postId: String) async throws {
        // First, fetch the current post to get the likes count
        let response = try await client
            .from("posts")
            .select()
            .eq("id", value: postId)
            .single()
            .execute()
        
        let post = try JSONDecoder().decode(PostModel.self, from: response.data)
        
        // Update the post with incremented likes
        try await client
            .from("posts")
            .update(["likes": post.likes + 1])
            .eq("id", value: postId)
            .execute()
    }
    
    // MARK: - Comments Methods
    
    // Fetch comments for a post
    func fetchComments(forPostId postId: String) async throws -> [Comment] {
        let response = try await client
            .from("comments")
            .select()
            .eq("post_id", value: postId)
            .order("created_at", ascending: false)
            .execute()
        
        let data = try JSONDecoder().decode([CommentModel].self, from: response.data)
        
        return data.map { model in
            Comment(
                id: model.id,
                text: model.content,
                username: model.username,
                timestamp: model.createdAt,
                likes: model.likes
            )
        }
    }
    
    // Add a comment to a post
    func addComment(comment: CommentModel) async throws -> CommentModel {
        let response = try await client
            .from("comments")
            .insert(comment)
            .single()
            .execute()
        
        let createdComment = try JSONDecoder().decode(CommentModel.self, from: response.data)
        
        // Update the comment count on the post using a different approach
        // Let's try using a direct database call instead of functions
        try await client
            .from("posts")
            .update(["comment_count": "comment_count + 1"])
            .eq("id", value: comment.postId)
            .execute()
        
        return createdComment
    }
    
    // MARK: - Course Methods
    
    // Fetch user's courses
    func fetchUserCourses(forUserId userId: String) async throws -> [Course] {
        let response = try await client
            .from("user_courses")
            .select("course_id, courses(id, course_code, professor_name)")
            .eq("user_id", value: userId)
            .execute()
        
        let data = try JSONDecoder().decode([UserCourseModel].self, from: response.data)
        
        return data.compactMap { model in
            guard let course = model.course else { return nil }
            
            return Course(
                id: course.id,
                courseCode: course.courseCode,
                professorName: course.professorName
            )
        }
    }
    
    // Add a course for user
    func addUserCourse(userId: String, courseId: String) async throws {
        let userCourse = UserCourseModel(userId: userId, courseId: courseId, course: nil)
        
        try await client
            .from("user_courses")
            .insert(userCourse)
            .execute()
    }
}

// MARK: - Database Models

struct UserModel: Codable {
    let id: String
    let email: String?
    let username: String
    var fullName: String?
    var avatarUrl: String?
    var university: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case fullName = "full_name"
        case avatarUrl = "avatar_url"
        case university
        case createdAt = "created_at"
    }
}

struct PostModel: Codable {
    let id: String
    let userId: String
    let content: String
    let courseCode: String
    let username: String
    var likes: Int
    var commentCount: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case content
        case courseCode = "course_code"
        case username
        case likes
        case commentCount = "comment_count"
        case createdAt = "created_at"
    }
}

struct CommentModel: Codable {
    let id: String
    let postId: String
    let userId: String
    let content: String
    let username: String
    var likes: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case userId = "user_id"
        case content
        case username
        case likes
        case createdAt = "created_at"
    }
}

struct CourseModel: Codable {
    let id: String
    let courseCode: String
    let professorName: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case courseCode = "course_code"
        case professorName = "professor_name"
    }
}

struct UserCourseModel: Codable {
    let userId: String
    let courseId: String
    let course: CourseModel?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case courseId = "course_id"
        case course = "courses"
    }
}
