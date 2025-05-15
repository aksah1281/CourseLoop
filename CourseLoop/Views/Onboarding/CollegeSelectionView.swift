import SwiftUI

struct CollegeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCollege: College? = nil
    @State private var isShowingUsernameScreen = false
    @State private var colleges: [College] = []
    @State private var isLoading = false
    @State private var hasSearched = false
    
    private let collegeService = CollegeScoreCardService()
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header with 3D effect
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Find your university")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "building.columns.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                            )
                    }
                    
                    Text("This helps connect you with students from your school")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // Search bar with animation
                HStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search university name", text: $searchText)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: searchText) { _, newValue in
                                if !newValue.isEmpty {
                                    isLoading = true
                                    hasSearched = true
                                    // Debounce the search
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        if searchText == newValue {
                                            collegeService.searchColleges(query: newValue) { result in
                                                colleges = result
                                                isLoading = false
                                            }
                                        }
                                    }
                                } else {
                                    colleges = []
                                    hasSearched = false
                                }
                            }
                    }
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                }
                .padding(.horizontal, 24)
                
                // Results section
                ZStack {
                    if isLoading {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.2)
                            
                            Text("Searching universities...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    } else if colleges.isEmpty && hasSearched {
                        VStack(spacing: 16) {
                            Image(systemName: "building.2.crop.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.6))
                            
                            Text("No universities found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Try another search term")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.8))
                        }
                        .padding(.top, 80)
                    } else if !hasSearched {
                        VStack(spacing: 16) {
                            Image(systemName: "building.columns.circle")
                                .font(.system(size: 48))
                                .foregroundColor(.blue.opacity(0.4))
                            
                            Text("Search for your university")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 80)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(colleges) { college in
                                    CollegeCard(
                                        college: college,
                                        isSelected: selectedCollege?.id == college.id,
                                        action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                selectedCollege = college
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 24)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                
                // Bottom button
                Button(action: {
                    if selectedCollege != nil {
                        isShowingUsernameScreen = true
                    }
                }) {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(selectedCollege != nil ?
                                  LinearGradient(colors: [.blue, .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                  LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: selectedCollege != nil ? .blue.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                    )
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }
                .disabled(selectedCollege == nil)
            }
        }
        .fullScreenCover(isPresented: $isShowingUsernameScreen) {
            UsernameSelectionView()
        }
    }
}

struct CollegeCard: View {
    let college: College
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(college.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if let city = college.city, let state = college.state {
                        Text("\(city), \(state)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: isSelected ? .blue.opacity(0.2) : .gray.opacity(0.1), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue.opacity(0.5) : Color.gray.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
}
