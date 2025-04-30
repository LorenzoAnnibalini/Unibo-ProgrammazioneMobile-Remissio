//
//  LookScreenView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 29/04/25.
//

import SwiftUI

struct LockScreenView: View {
    @ObservedObject var authManager: AuthenticationManager
    @State private var enteredPIN = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("🔒 App protetta")
                .font(.largeTitle)

            SecureField("Inserisci il PIN", text: $enteredPIN)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 200)

            Button("Sblocca") {
                if authManager.checkPIN(enteredPIN) {
                    authManager.isAuthenticated = true
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Face ID / Touch ID") {
                authManager.authenticateWithBiometrics()
            }
            .foregroundColor(.blue)
        }
        .padding()
    }
}
