//
//  ProfiloView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 22/03/25.
//

import SwiftUI

struct ProfiloView: View {
    @StateObject private var viewModel = ProfiloViewModel()
    @EnvironmentObject var authManager: AuthenticationManager

    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    @State private var showingPINChangeView = false
    @State private var localProtectionEnabled: Bool = UserDefaults.standard.bool(forKey: "protectionEnabled")
    @State private var isActivatingProtection: Bool = false
    @State private var pendingEnableProtection: Bool = false

    let sessi = ["Maschio", "Femmina", "Altro"]
    let etàOptions = Array(0...120).map { String($0) }

    var body: some View {
        Form {
            Section {
                VStack {
                    if let data = viewModel.profilo.fotoProfiloData,
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                            .padding()
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                            .padding()
                    }

                    HStack {
                        Button("📸 Scatta foto") {
                            sourceType = .camera
                            showingImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)

                        Button("🖼️ Scegli foto") {
                            sourceType = .photoLibrary
                            showingImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Section(header: Text("Informazioni Anagrafiche")) {
                TextField("Nome", text: $viewModel.profilo.nome)
                TextField("Cognome", text: $viewModel.profilo.cognome)
                TextField("Codice Fiscale", text: $viewModel.profilo.codiceFiscale)

                Picker("Sesso", selection: $viewModel.profilo.sesso) {
                    ForEach(sessi, id: \.self) { sesso in
                        Text(sesso)
                    }
                }

                Picker("Età", selection: $viewModel.profilo.eta) {
                    ForEach(etàOptions, id: \.self) { eta in
                        Text(eta)
                    }
                }

                TextField("Data di Nascita (es: 01/01/1990)", text: $viewModel.profilo.dataDiNascita)
                TextField("Luogo di Nascita", text: $viewModel.profilo.luogo)
                TextField("Residenza", text: $viewModel.profilo.residenza)
            }

            Section(header: Text("Dati Sanitari")) {
                TextField("Altezza (cm)", text: $viewModel.profilo.altezza)
                    .keyboardType(.numberPad)

                TextField("Tipo Malattia (max 50 caratteri)", text: $viewModel.profilo.tipoMalattia)
                    .onChange(of: viewModel.profilo.tipoMalattia) { newValue in
                        if newValue.count > 50 {
                            viewModel.profilo.tipoMalattia = String(newValue.prefix(50))
                        }
                    }
            }

            Section(header: Text("Sicurezza")) {
                Toggle("Protezione attiva", isOn: $localProtectionEnabled)
                    .onChange(of: localProtectionEnabled) { newValue in
                        if newValue {
                            pendingEnableProtection = true
                        } else {
                            authManager.disableProtection()
                        }
                    }

                Button("Cambia PIN") {
                    isActivatingProtection = false
                    showingPINChangeView = true
                }
            }

            Button(action: {
                viewModel.saveProfilo()
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Salva Profilo")
                        .bold()
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .navigationTitle("Profilo")

        // Sheet per cambiare/creare PIN
        .sheet(isPresented: $showingPINChangeView) {
            ChangePINView(onComplete: { success in
                if success {
                    authManager.isProtectionEnabled = true
                    localProtectionEnabled = true
                } else {
                    if isActivatingProtection {
                        localProtectionEnabled = false
                    }
                }
            })
            .environmentObject(authManager)
        }

        // Sheet trigger separato
        .onChange(of: pendingEnableProtection) { shouldShow in
            if shouldShow {
                isActivatingProtection = true
                showingPINChangeView = true
                pendingEnableProtection = false
            }
        }

        // Sheet per immagine
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(sourceType: sourceType, selectedImage: $inputImage)
        }
    }

    private func loadImage() {
        guard let inputImage = inputImage else { return }
        viewModel.profilo.fotoProfiloData = inputImage.jpegData(compressionQuality: 0.8)
        viewModel.saveProfilo()
    }
}

struct ProfiloView_Previews: PreviewProvider {
    static var previews: some View {
        ProfiloView().environmentObject(AuthenticationManager())
    }
}
