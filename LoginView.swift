//
//  LoginView.swift
//  BoyerLindsey-Project
//
//  Created by Lindsey Boyer on 11/23/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    
    // trying to make a custom nav bar (back to content view)
    init() {
        let appearance = UINavigationBarAppearance()
        
        // custom blue color
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.20, green: 0.40, blue: 0.60, alpha: 1.0)
        
        // title text
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // change 'back' btn text so it's readable
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        buttonAppearance.highlighted.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backButtonAppearance = buttonAppearance
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    // MARK: User Login Variables
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    @State private var showSignUpAlert = false
    @State private var signUpEmail: String = ""
    @State private var signUpPassword: String = ""
    
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var userData: UserData

    var body: some View {
        VStack(spacing: 32) {
            
            // email text field
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your email")
                    .font(.custom("Manrope", size: 16).weight(.medium))
                    .foregroundColor(.primary)
                
                TextField("example@email", text: $email)
                    .font(.custom("Manrope", size: 14))
                    .padding(13)
                    .frame(width: 320)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
                    )
                    // ensure tint is ok for light/dark changes
                    .tint(.primary)
                    .autocapitalization(.none)
            }
            .padding(.top, 40)
            
            // password text field
            VStack(alignment: .leading, spacing: 8) {
                Text("Enter your password")
                    .font(.custom("Manrope", size: 16).weight(.medium))
                    .foregroundColor(.primary)
                
                // secure field so password is hidden
                SecureField("password", text: $password)
                    .font(.custom("Manrope", size: 14))
                    .padding(13)
                    .frame(width: 320)
                    .background(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary.opacity(0.2), lineWidth: 0.5)
                    )
                    .tint(.primary)
                    .autocapitalization(.none)
            }
            
            // MARK: Sign-In Btn
            Button(action: { signIn() }) {
                
                // custom color and shape
                Text("Sign In")
                    .font(.custom("Manrope", size: 20).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(width: 173, height: 50)
                    .background(Color(red: 0.20, green: 0.40, blue: 0.60))
                    .cornerRadius(20)
            }
            .shadow(color: .black.opacity(0.25), radius: 10, x: 4, y: 4)
            .padding(.top, 60)
            
            // MARK: Sign-Up Btn
            Button(action: {
                signUpEmail = ""
                signUpPassword = ""
                showSignUpAlert = true
            }) {
                Text("Sign Up")
                    .font(.custom("Manrope", size: 16))
                    .foregroundColor(.secondary)
                    .underline()
            }
            .padding(.top, -4)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        
        // MARK: Login Alerts
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("OK")))
        }
        .alert("Sign Up", isPresented: $showSignUpAlert) {
            TextField("Email", text: $signUpEmail)
                .autocapitalization(.none)
            TextField("Password", text: $signUpPassword)
                .autocapitalization(.none)
            Button("Cancel", role: .cancel) { }
            Button("OK") { signUp() }
        } message: {
            Text("Enter your email and password to create a new account.")
        }
    }
    
    // MARK: Func - Firebase Auth
    private func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            // make sure entries are correct
            if let error = error {
                errorMessage = "Username or password not recognized: \(error.localizedDescription)"
                showErrorAlert = true
            } else {
                // sign-in success and go to search view
                DispatchQueue.main.async {
                    navigationState.navigateToSearch()
                }
            }
        }
    }
    
    // MARK: Func - Firebase Sign-Up
    private func signUp() {
        guard !signUpEmail.isEmpty, !signUpPassword.isEmpty else { return }
        
        Auth.auth().createUser(withEmail: signUpEmail, password: signUpPassword) { result, error in
            if let error = error {
                errorMessage = "Sign up failed: \(error.localizedDescription)"
                showErrorAlert = true
            } else {
                // login user in and send them to the search view
                email = signUpEmail
                password = signUpPassword
                signIn()
            }
        }
    }
}

#Preview {
    LoginView()
}
