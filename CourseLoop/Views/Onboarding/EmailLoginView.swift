//
//  LoginView.swift
//  CourseLoop
//
//  Created by Akash Patel on 4/19/25.
//
import SwiftUI
import Combine

struct EmailLoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isShowingOTPScreen = false
    @State private var isEmailValid = false
    @State private var keyboardShown = false
    
    // Email validation
    private func validateEmail() {
        let emailPattern = #"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.edu"#
        let result = email.range(of: emailPattern, options: .regularExpression)
        isEmailValid = (result != nil)
    }
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    HStack {
                        Text("Verify your .edu email")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color.green.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            )
                    }
                    
                    Text("We'll send a verification code to your school email")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // Email card with subtle animation
                VStack(alignment: .leading, spacing: 16) {
                    Text("School Email")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.leading, 4)
                    
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.green)
                            .font(.system(size: 18))
                            .frame(width: 24)
                        
                        TextField("you@university.edu", text: $email)
                            .font(.system(size: 17))
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: email) { _, newValue in
                                validateEmail()
                            }
                            .onSubmit {
                                if isEmailValid {
                                    isShowingOTPScreen = true
                                }
                            }
                        
                        if !email.isEmpty {
                            Button(action: {
                                withAnimation {
                                    email = ""
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isEmailValid ? Color.green.opacity(0.5) : Color.clear, lineWidth: 1.5)
                    )
                    
                    // Validation message
                    if !email.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: isEmailValid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                                .foregroundColor(isEmailValid ? .green : .red)
                                .font(.system(size: 14))
                            
                            Text(isEmailValid ? "Valid school email" : "Please enter a valid .edu email address")
                                .font(.caption)
                                .foregroundColor(isEmailValid ? .green : .red)
                        }
                        .padding(.leading, 4)
                        .transition(.opacity)
                        .animation(.easeInOut, value: isEmailValid)
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Continue button with gradient - Conditional padding based on keyboard
                Button(action: {
                    if isEmailValid {
                        isShowingOTPScreen = true
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
                            .fill(isEmailValid ?
                                  LinearGradient(colors: [.green, .blue], startPoint: .leading, endPoint: .trailing) :
                                  LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: isEmailValid ? .green.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                    )
                }
                .disabled(!isEmailValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            // Register for keyboard notifications
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                keyboardShown = true
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardShown = false
            }
        }
        .gesture(TapGesture().onEnded {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        })
        .fullScreenCover(isPresented: $isShowingOTPScreen) {
            OTPVerificationView(email: email)
        }
    }
}


import SwiftUI
import Combine

struct OTPVerificationView: View {
    let email: String
    @Environment(\.dismiss) private var dismiss
    @State private var otpCode = ""
    @State private var isShowingMainScreen = false
    @State private var timeRemaining = 60
    @State private var timer: Timer? = nil
    @State private var keyboardShown = false
    @FocusState private var isOtpFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    
                    HStack {
                        Text("Verification Code")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
                            )
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color.orange.opacity(0.15))
                            .frame(width: 48, height: 48)
                            .overlay(
                                Image(systemName: "key.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.orange)
                            )
                    }
                    
                    Text("We've sent a code to \(email)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 32)
                
                // OTP Input with regular text field
                VStack(spacing: 24) {
                    Text("Enter verification code")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Regular OTP text field
                    HStack {
                        Image(systemName: "key")
                            .foregroundColor(.orange)
                            .font(.system(size: 18))
                            .frame(width: 24)
                        
                        TextField("Enter 6-digit code", text: $otpCode)
                            .font(.system(size: 20, weight: .medium))
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .focused($isOtpFieldFocused)
                            .onReceive(Just(otpCode)) { newValue in
                                // Only allow up to 6 numeric characters
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue || filtered.count > 6 {
                                    otpCode = String(filtered.prefix(6))
                                }
                                
                                // Auto-dismiss keyboard when 6 digits entered
                                if otpCode.count == 6 {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        isOtpFieldFocused = false
                                    }
                                }
                            }
                            
                        if !otpCode.isEmpty {
                            Button(action: {
                                withAnimation {
                                    otpCode = ""
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.5), lineWidth: 1.5)
                    )
                    .padding(.horizontal)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Conditional spacing - Show only when keyboard isn't displayed
                if !keyboardShown {
                    // Resend code section
                    VStack(spacing: 12) {
                        if timeRemaining > 0 {
                            Text("Resend code in \(timeRemaining)s")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .onAppear {
                                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                        if timeRemaining > 0 {
                                            timeRemaining -= 1
                                        } else {
                                            timer?.invalidate()
                                        }
                                    }
                                }
                        } else {
                            Button(action: {
                                // Resend OTP logic
                                timeRemaining = 60
                                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    if timeRemaining > 0 {
                                        timeRemaining -= 1
                                    } else {
                                        timer?.invalidate()
                                    }
                                }
                            }) {
                                Text("Resend Code")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.orange)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(Color.orange.opacity(0.15))
                                    )
                            }
                        }
                        
                        Button("Didn't receive a code?") {
                            // Help action
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 24)
                }
                
                // Verify button
                Button(action: {
                    if otpCode.count == 6 {
                        isShowingMainScreen = true
                    }
                }) {
                    HStack {
                        Text("Verify")
                            .fontWeight(.semibold)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(otpCode.count == 6 ?
                                  LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) :
                                  LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                            .shadow(color: otpCode.count == 6 ? .orange.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
                    )
                }
                .disabled(otpCode.count != 6)
                .padding(.horizontal, 24)
                .padding(.bottom, keyboardShown ? 16 : 24)
            }
        }
        .onAppear {
            // Register for keyboard notifications
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardShown = true
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardShown = false
            }
            
            // Auto-focus OTP field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isOtpFieldFocused = true
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .fullScreenCover(isPresented: $isShowingMainScreen) {
            CollegeSelectionView()
        }
    }
}
