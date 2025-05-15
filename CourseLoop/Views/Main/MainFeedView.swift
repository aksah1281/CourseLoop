//
//  MainFeedView.swift
//  CourseLoop
//
//  Created by Akash Patel on 5/13/25.
//

import SwiftUI

struct MainFeedView: View {
    @State private var postText = ""
    @State private var posts: [Post] = samplePosts
    @State private var isShowingNewPostSheet = false
    @State private var refreshing = false
    @State private var selectedFeedFilter: FeedFilter = .all
    
    enum FeedFilter {
        case all, myCourses, trending
    }
    
    var filteredPosts: [Post] {
        switch selectedFeedFilter {
        case .all:
            return posts
        case .myCourses:
            // Simulate my courses with a few course codes
            let myCourses = ["CS101", "MATH201", "PHYS150"]
            return posts.filter { myCourses.contains($0.courseCode) }
        case .trending:
            return posts.sorted { $0.likes > $1.likes }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Feed filter tabs
                    HStack(spacing: 0) {
                        FeedFilterTab(title: "All", isSelected: selectedFeedFilter == .all) {
                            withAnimation {
                                selectedFeedFilter = .all
                            }
                        }
                        
                        FeedFilterTab(title: "My Courses", isSelected: selectedFeedFilter == .myCourses) {
                            withAnimation {
                                selectedFeedFilter = .myCourses
                            }
                        }
                        
                        FeedFilterTab(title: "Trending", isSelected: selectedFeedFilter == .trending) {
                            withAnimation {
                                selectedFeedFilter = .trending
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Pull to refresh control
                            RefreshControl(refreshing: $refreshing) {
                                // Simulate refresh with delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    withAnimation {
                                        self.refreshing = false
                                    }
                                }
                            }
                            
                            // Post feed
                            ForEach(filteredPosts) { post in
                                PostCard(post: post)
                                
                                Divider()
                                    .padding(.horizontal)
                                    .opacity(0.5)
                            }
                            
                            // Bottom space for FAB
                            Color.clear.frame(height: 80)
                        }
                    }
                }
                
                // Floating Action Button (New Post)
                Button(action: {
                    isShowingNewPostSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        )
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle("Course Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Course Feed")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Filter action
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $isShowingNewPostSheet) {
                NewPostView { newPost in
                    // Add the new post to the top of the feed
                    withAnimation {
                        posts.insert(newPost, at: 0)
                    }
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

// Feed filter tab
struct FeedFilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Simulated pull-to-refresh control
struct RefreshControl: View {
    @Binding var refreshing: Bool
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            if geo.frame(in: .global).minY > 20 && !refreshing {
                Spacer()
                    .onAppear {
                        refreshing = true
                        action()
                    }
            } else if refreshing {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(width: 50, height: 50)
                    Spacer()
                }
            }
        }.frame(height: refreshing ? 50 : 0)
    }
}

// Post creation view
struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    @State private var selectedCourse: Course? = nil
    @State private var courses: [Course] = [
        Course(id: "1", courseCode: "CS101", professorName: "Smith, J"),
        Course(id: "2", courseCode: "MATH201", professorName: "Johnson, K"),
        Course(id: "3", courseCode: "PHYS150", professorName: "Garcia, M")
    ]
    
    let onPost: (Post) -> Void
    
    private var isPostValid: Bool {
        return !postText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedCourse != nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Course selection
                Menu {
                    ForEach(courses) { course in
                        Button(action: {
                            selectedCourse = course
                        }) {
                            HStack {
                                Text(course.courseCode)
                                if selectedCourse?.id == course.id {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundColor(.blue)
                        
                        Text(selectedCourse?.courseCode ?? "Select a course")
                            .foregroundColor(selectedCourse != nil ? .primary : .secondary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    .padding(.top)
                }
                
                // Divider
                Divider()
                    .padding(.top)
                
                // Post text area
                TextEditor(text: $postText)
                    .font(.body)
                    .padding(4)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .overlay(
                        VStack {
                            HStack {
                                Text("What's your question or insight?")
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 8)
                                Spacer()
                            }
                            Spacer()
                        }
                        .opacity(postText.isEmpty ? 1 : 0),
                        alignment: .topLeading
                    )
                    .padding(.horizontal)
                
                // Character count
                HStack {
                    Spacer()
                    Text("\(postText.count)/280")
                        .font(.caption)
                        .foregroundColor(postText.count > 280 ? .red : .secondary)
                        .padding(.trailing)
                }
                .padding(.bottom, 8)
                
                Divider()
                
                // Action buttons
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if isPostValid && postText.count <= 280 {
                            let newPost = Post(
                                id: UUID().uuidString,
                                text: postText,
                                timestamp: Date(),
                                username: "SwiftUser123",
                                courseCode: selectedCourse!.courseCode,
                                likes: 0,
                                comments: 0
                            )
                            onPost(newPost)
                            dismiss()
                        }
                    }) {
                        Text("Post")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                Capsule()
                                    .fill(isPostValid && postText.count <= 280 ?
                                          LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                                          LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            )
                    }
                    .disabled(!isPostValid || postText.count > 280)
                }
                .padding()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Post card component
struct PostCard: View {
    let post: Post
    @State private var isLiked = false
    @State private var showingComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header info (username and course)
            HStack {
                // Avatar placeholder
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(post.username.prefix(1).uppercased()))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.blue)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(post.courseCode)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time indicator
                Text(post.formattedTime)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            // Post content
            Text(post.text)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Action buttons
            HStack(spacing: 24) {
                // Comment button
                Button(action: {
                    showingComments = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16))
                        Text("\(post.comments)")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                }
                
                // Like button
                Button(action: {
                    isLiked.toggle()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                        Text("\(post.likes + (isLiked ? 1 : 0))")
                            .font(.system(size: 14))
                    }
                    .foregroundColor(isLiked ? .red : .secondary)
                }
                
                // Share button
                Button(action: {
                    // Share logic
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .sheet(isPresented: $showingComments) {
            CommentsView(post: post)
                .presentationDetents([.medium, .large])
        }
    }
}

// Comments view
struct CommentsView: View {
    let post: Post
    @State private var commentText = ""
    @State private var comments: [Comment] = sampleComments
    
    var body: some View {
        NavigationStack {
            VStack {
                // Original post reference
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(post.username)
                            .font(.system(size: 15, weight: .semibold))
                        
                        Text("• \(post.courseCode)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                    }
                    
                    Text(post.text)
                        .font(.system(size: 15))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Comments
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(comments) { comment in
                            CommentCard(comment: comment)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Comment input
                HStack(spacing: 12) {
                    // Avatar placeholder
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Text("Me")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.blue)
                        )
                    
                    // Text input
                    TextField("Add a comment...", text: $commentText)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    
                    // Send button
                    Button(action: {
                        if !commentText.isEmpty {
                            let newComment = Comment(
                                id: UUID().uuidString,
                                text: commentText,
                                username: "Me",
                                timestamp: Date(),
                                likes: 0
                            )
                            comments.insert(newComment, at: 0)
                            commentText = ""
                        }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16))
                            .foregroundColor(!commentText.isEmpty ? .blue : .gray)
                            .padding(8)
                    }
                    .disabled(commentText.isEmpty)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Comment card
struct CommentCard: View {
    let comment: Comment
    @State private var isLiked = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar placeholder
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 36, height: 36)
                .overlay(
                    Text(String(comment.username.prefix(1).uppercased()))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                )
            
            VStack(alignment: .leading, spacing: 6) {
                // Comment header
                HStack {
                    Text(comment.username)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Spacer()
                    
                    Text(comment.formattedTime)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                
                // Comment text
                Text(comment.text)
                    .font(.system(size: 15))
                    .fixedSize(horizontal: false, vertical: true)
                
                // Actions
                HStack(spacing: 16) {
                    Button(action: {
                        isLiked.toggle()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .font(.system(size: 14))
                            Text("\(comment.likes + (isLiked ? 1 : 0))")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(isLiked ? .red : .secondary)
                    }
                    
                    Button(action: {
                        // Reply logic
                    }) {
                        Text("Reply")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: - Models
struct Post: Identifiable {
    let id: String
    let text: String
    let timestamp: Date
    let username: String
    let courseCode: String
    let likes: Int
    let comments: Int
    
    var formattedTime: String {
        // Simplified for example
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct Comment: Identifiable {
    let id: String
    let text: String
    let username: String
    let timestamp: Date
    let likes: Int
    
    var formattedTime: String {
        // Simplified for example
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

struct Course: Identifiable {
    let id: String
    let courseCode: String
    let professorName: String
}

// MARK: - Sample Data
// Sample posts
let samplePosts = [
    Post(id: "1",
         text: "Does anyone understand the content from today's lecture on neural networks? I'm completely lost on backpropagation.",
         timestamp: Date().addingTimeInterval(-5 * 60),
         username: "NeuralNovice",
         courseCode: "CS356",
         likes: 5,
         comments: 3),
    
    Post(id: "2",
         text: "Anyone else struggling with problem set 3? The recursion questions are killing me! 😫",
         timestamp: Date().addingTimeInterval(-45 * 60),
         username: "RecursiveThinker",
         courseCode: "CS201",
         likes: 12,
         comments: 8),
    
    Post(id: "3",
         text: "Study group forming for the calculus midterm this weekend. We'll be in the library, 3rd floor, from 2-5pm. All welcome!",
         timestamp: Date().addingTimeInterval(-3 * 3600),
         username: "CalcChampion",
         courseCode: "MATH201",
         likes: 24,
         comments: 15),
    
    Post(id: "4",
         text: "Anyone have Professor Miller's notes from last Thursday? I missed class due to illness.",
         timestamp: Date().addingTimeInterval(-1 * 86400),
         username: "ClassNoteCollector",
         courseCode: "BIO240",
         likes: 3,
         comments: 2),
    
    Post(id: "5",
         text: "Pro tip: The lab assistants hold extra office hours on Wednesdays that aren't on the syllabus. They're much less crowded!",
         timestamp: Date().addingTimeInterval(-2 * 86400),
         username: "LabMaster",
         courseCode: "CHEM188",
         likes: 35,
         comments: 4)
]

// Sample comments
let sampleComments = [
    Comment(id: "1",
            text: "I can help! Backpropagation is just applying the chain rule from calculus to find gradients through the network. DM me if you want to meet up.",
            username: "DeepLearner",
            timestamp: Date().addingTimeInterval(-2 * 60),
            likes: 3),
    
    Comment(id: "2",
            text: "Check out the Khan Academy videos on neural networks - they really helped me understand the concepts.",
            username: "VideoLearner",
            timestamp: Date().addingTimeInterval(-20 * 60),
            likes: 5),
    
    Comment(id: "3",
            text: "Professor Johnson also has some great office hours on Thursdays where she specifically goes over these topics again.",
            username: "OfficeSage",
            timestamp: Date().addingTimeInterval(-45 * 60),
            likes: 2)
]
