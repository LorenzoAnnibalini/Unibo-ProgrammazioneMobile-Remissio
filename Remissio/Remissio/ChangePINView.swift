//
//  ChangePINView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 29/04/25.
//

import SwiftUI

struct ChangePINView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss

    var onComplete: ((Bool) -> Void)? // ✅ callback

    @State private var currentPIN: String = ""
    @State private var newPIN: String = ""
    @State private var confirmPIN: String = ""
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                if authManager.isProtectionEnabled {
                    Section(header: Text("PIN Attuale")) {
                        SecureField("PIN attuale", text: $currentPIN)
                            .keyboardType(.numberPad)
                    }
                }

                Section(header: Text("Nuovo PIN")) {
                    SecureField("Nuovo PIN", text: $newPIN)
                        .keyboardType(.numberPad)
                    SecureField("Conferma nuovo PIN", text: $confirmPIN)
                        .keyboardType(.numberPad)
                }

                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }

                Section {
                    Button("Salva") {
                        handlePINChange()
                    }
                    .disabled(!canSave)
                }
            }
            .navigationTitle("Cambia PIN")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        onComplete?(false) // ❌ non salvato
                        dismiss()
                    }
                }
            }
        }
    }

    private var canSave: Bool {
        !newPIN.isEmpty && newPIN == confirmPIN && newPIN.count >= 4
    }

    private func handlePINChange() {
        guard newPIN == confirmPIN else {
            errorMessage = "Il nuovo PIN non coincide."
            return
        }

        let success = authManager.changePIN(currentPIN: authManager.isProtectionEnabled ? currentPIN : nil, newPIN: newPIN)

        if success {
            errorMessage = nil
            onComplete?(true) // ✅ PIN salvato
            dismiss()
        } else {
            errorMessage = "PIN attuale errato."
        }
    }
}
