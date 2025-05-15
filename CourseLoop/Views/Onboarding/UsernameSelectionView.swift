//
//  UsernameSelectionView.swift
//  CourseLoop
//
//  Created by Akash Patel on 4/19/25.
//

import SwiftUI

struct UsernameSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var username = ""
    @State private var isUsernameValid = false
    @State private var isShowingEmailLogin = false
    @State private var isGeneratingUsername = false
    @State private var suggestedUsernames: [String] = []
    @State private var selectedSuggestionIndex: Int? = nil
    
    // List of adjectives and nouns for username generation
    private let adjectives = ["Swift", "Bright", "Clever", "Dynamic", "Epic", "Focused", "Golden", "Hidden", "Infinite", "Jubilant", "Keen", "Lively", "Mighty", "Noble", "Optimal", "Prime", "Quick", "Radiant", "Silent", "Tactical", "Unique", "Vibrant", "Whimsical", "Xenial", "Zealous"]
    
    private let nouns = ["Eagle", "Tiger", "Scholar", "Genius", "Phoenix", "Voyager", "Pioneer", "Hero", "Legend", "Prodigy", "Maven", "Guru", "Master", "Ninja", "Wizard", "Champion", "Captain", "Knight", "Sage", "Explorer", "Pilot", "Ranger", "Sentinel", "Guardian", "Seeker"]
    
    private func generateRandomUsernames(count: Int = 5) -> [String] {
        var usernames: [String] = []
        
        for _ in 0..<count {
            let adjective = adjectives.randomElement() ?? "Anonymous"
            let noun = nouns.randomElement() ?? "User"
            let number = Int.random(in: 10...999)
            
            usernames.append("\(adjective)\(noun)\(number)")
        }
        
        return usernames
    }
    
    private func validateUsername() {
        // Username must be at least 3 characters and contain only letters, numbers, and underscores
        let usernamePattern = "^[a-zA-Z0-9_]{3,20}$"
        let result = username.range(of: usernamePattern, options: .regularExpression)
        isUsernameValid = (result != nil)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 20)
                
                Text("Create your identity")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("This is how other students will see you")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding([.horizontal, .top], 24)
            .padding(.bottom, 32)
            
            // Username input
            VStack(alignment: .leading, spacing: 10) {
                Text("Your username")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.leading, 4)
                
                HStack {
                    TextField("Enter username", text: $username)
                        .font(.system(size: 17))
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                        )
                        .onChange(of: username) { _, newValue in
                            validateUsername()
                        }
                    
                    if !username.isEmpty {
                        Button(action: {
                            username = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        }
                    }
                }
                
                // Validation message
                if !username.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: isUsernameValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(isUsernameValid ? .green : .red)
                            .font(.system(size: 14))
                        
                        Text(isUsernameValid ? "Username is valid" : "3-20 characters, letters, numbers, underscores only")
                            .font(.caption)
                            .foregroundColor(isUsernameValid ? .green : .red)
                    }
                    .padding(.leading, 4)
                }
            }
            .padding(.horizontal, 24)
            
            // Suggestions section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Suggested usernames")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        isGeneratingUsername = true
                        selectedSuggestionIndex = nil
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            suggestedUsernames = generateRandomUsernames()
                            isGeneratingUsername = false
                        }
                    }) {
                        HStack(spacing: 6) {
                            if isGeneratingUsername {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 14))
                            }
                            
                            Text("New suggestions")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                // Suggestions chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(suggestedUsernames.indices, id: \.self) { index in
                            let suggestion = suggestedUsernames[index]
                            
                            Button(action: {
                                username = suggestion
                                selectedSuggestionIndex = index
                                validateUsername()
                            }) {
                                Text(suggestion)
                                    .font(.system(size: 15, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedSuggestionIndex == index ?
                                                  Color.blue.opacity(0.2) : Color(.systemGray6))
                                    )
                                    .foregroundColor(selectedSuggestionIndex == index ? .blue : .primary)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
            }
            
            Spacer()
            
            // Continue button
            Button(action: {
                if isUsernameValid {
                    isShowingEmailLogin = true
                }
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isUsernameValid ? Color.blue : Color.gray.opacity(0.5))
                    )
            }
            .disabled(!isUsernameValid)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            suggestedUsernames = generateRandomUsernames()
        }
        .fullScreenCover(isPresented: $isShowingEmailLogin) {
            CourseInputView()
        }
    }
}
