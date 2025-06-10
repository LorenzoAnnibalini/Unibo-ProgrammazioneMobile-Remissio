//
//  AuthenticationManager.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 29/04/25.
//

import LocalAuthentication
import Security
import Combine

class AuthenticationManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isProtectionEnabled: Bool = UserDefaults.standard.bool(forKey: "protectionEnabled")

    private let service = "com.remissioApp.pin"
    private let account = "userPIN"

    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sblocca l'app") { success, _ in
                DispatchQueue.main.async {
                    self.isAuthenticated = success
                }
            }
        }
    }
    
    func changePIN(currentPIN: String?, newPIN: String) -> Bool {
        if isProtectionEnabled {
            // Se la protezione è attiva, verifica che il PIN attuale sia corretto
            guard let currentPIN = currentPIN, checkPIN(currentPIN) else {
                return false // PIN attuale errato o mancante
            }
        }

        // Salva il nuovo PIN
        savePIN(newPIN)
        return true
    }
    
    func checkPINFromKeychain() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]
        
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        return status == errSecSuccess
    }


    func savePIN(_ pin: String) {
        //Attivo il flag per la protezione con pin
        UserDefaults.standard.set(true, forKey: "protectionEnabled")
        isProtectionEnabled = true

        //QUERY nuovo PIN
        let data = Data(pin.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        //Inserisco il pin cancellando un eventuale pin vecchio
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    func checkPIN(_ pin: String) -> Bool {
        //QUERY per leggere il pin
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true
        ]

        //Avvio la QUERY
        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecSuccess,
           let data = item as? Data,
           let savedPIN = String(data: data, encoding: .utf8) {
            return savedPIN == pin
        }

        return false
    }

    func disableProtection() {
        //Disattivo il flag per la protezione con pin
        UserDefaults.standard.set(false, forKey: "protectionEnabled")
        isProtectionEnabled = false
        
        //Cerco il pin con una QUERY
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        //Elimina il PIN dal Keychain
        SecItemDelete(query as CFDictionary)
    }
}
