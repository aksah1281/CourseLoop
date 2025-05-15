import SwiftUI

struct CourseInputView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var currentCourses: [CourseEntry] = []
    @State private var previousCourses: [CourseEntry] = []
    @State private var isShowingAddSheet = false
    @State private var isShowingMainView = false
    
    private var hasMinimumCourses: Bool {
        return !currentCourses.isEmpty && !previousCourses.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Your Courses")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Add courses you're taking now and from last semester")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)
            
            // Tab selection
            HStack(spacing: 0) {
                TabButton(title: "Current", isSelected: selectedTab == 0) {
                    withAnimation {
                        selectedTab = 0
                    }
                }
                
                TabButton(title: "Previous", isSelected: selectedTab == 1) {
                    withAnimation {
                        selectedTab = 1
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            
            // Course lists
            ZStack {
                // Current courses
                if selectedTab == 0 {
                    CourseListView(
                        courses: $currentCourses,
                        emptyCourseMessage: "Add courses you're currently taking",
                        onAddTap: {
                            isShowingAddSheet = true
                        }
                    )
                    .transition(.opacity)
                }
                
                // Previous courses
                if selectedTab == 1 {
                    CourseListView(
                        courses: $previousCourses,
                        emptyCourseMessage: "Add courses from last semester",
                        onAddTap: {
                            isShowingAddSheet = true
                        }
                    )
                    .transition(.opacity)
                }
            }
            .padding(.top, 16)
            
            // Continue button
            Button(action: {
                isShowingMainView = true
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(hasMinimumCourses ? Color.blue : Color.gray.opacity(0.5))
                    )
            }
            .disabled(!hasMinimumCourses)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $isShowingAddSheet) {
            CourseEntrySheet(onSave: { course in
                if selectedTab == 0 {
                    currentCourses.append(course)
                } else {
                    previousCourses.append(course)
                }
            })
            .presentationDetents([.height(400)])
        }
        .fullScreenCover(isPresented: $isShowingMainView) {
            MainFeedView()
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .padding(.vertical, 8)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CourseListView: View {
    @Binding var courses: [CourseEntry]
    let emptyCourseMessage: String
    let onAddTap: () -> Void
    
    var body: some View {
        ZStack {
            // Empty state
            if courses.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary.opacity(0.6))
                    
                    Text(emptyCourseMessage)
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: onAddTap) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                            
                            Text("Add Course")
                                .fontWeight(.medium)
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                }
                .padding(24)
            }
            // Course list
            else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(courses) { course in
                            CourseCard(course: course, onDelete: {
                                if let index = courses.firstIndex(where: { $0.id == course.id }) {
                                    courses.remove(at: index)
                                }
                            })
                        }
                        
                        Button(action: onAddTap) {
                            HStack {
                                Image(systemName: "plus")
                                    .font(.system(size: 14))
                                
                                Text("Add Another Course")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 1.5)
                                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.blue.opacity(0.05)))
                            )
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(maxHeight: .infinity)
    }
}

struct CourseCard: View {
    let course: CourseEntry
    let onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(course.courseCode)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(course.professorName)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.8))
                    .padding(10)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.1))
                    )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 5, x: 0, y: 2)
        )
    }
}

struct CourseEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var courseCode = ""
    @State private var professorName = ""
    @State private var suggestedCourses: [String] = [] // For auto-suggest
    @State private var suggestedProfessors: [String] = [] // For auto-suggest
    @State private var isLoading = false
    
    let onSave: (CourseEntry) -> Void
    
    private var isFormValid: Bool {
        return !courseCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !professorName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // Function to standardize course code (uppercase, remove special chars)
    private func standardizeCourseCode(_ code: String) -> String {
        let alphanumeric = code.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        return alphanumeric.uppercased()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Add Course")
                    .font(.system(size: 22, weight: .bold))
                
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
            .padding(20)
            
            // Divider
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 1)
            
            // Form
            VStack(spacing: 24) {
                // Course code field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Course Code")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Enter course code (e.g., CS101)", text: $courseCode)
                            .font(.system(size: 17))
                            .onChange(of: courseCode) { _, newValue in
                                // Auto-suggest logic would go here
                                // For now, just transform to uppercase as they type
                                if courseCode != newValue.uppercased() {
                                    courseCode = newValue.uppercased()
                                }
                            }
                        
                        if !courseCode.isEmpty {
                            Button(action: {
                                courseCode = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    
                    Text("Course codes will be formatted to uppercase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Professor name field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Professor")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("Last, First", text: $professorName)
                            .font(.system(size: 17))
                        
                        if !professorName.isEmpty {
                            Button(action: {
                                professorName = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    
                    Text("Enter as 'Last, First'")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Save button
                Button(action: {
                    let standardizedCode = standardizeCourseCode(courseCode)
                    let entry = CourseEntry(
                        courseCode: standardizedCode,
                        professorName: professorName
                    )
                    onSave(entry)
                    dismiss()
                }) {
                    Text("Save Course")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isFormValid ? Color.blue : Color.gray.opacity(0.5))
                        )
                }
                .disabled(!isFormValid)
            }
            .padding(20)
            
            Spacer()
        }
    }
}

struct CourseEntry: Identifiable {
    let id = UUID()
    let courseCode: String
    let professorName: String
}



struct CourseInputView_Previews: PreviewProvider {
    static var previews: some View {
        CourseInputView()
    }
}
