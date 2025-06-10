//
//  InserimentoStatoSaluteView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 24/04/25.
//
import SwiftUI
import CoreLocation


struct InputField: View {
    var label: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.headline).foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .padding()
                .background(.thinMaterial)
                .cornerRadius(15)
                .keyboardType(keyboardType)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        }
        .padding(.horizontal)
    }
}

struct InserimentoStatoSaluteViewWrapper: View {
    @Binding var statiSalute: [StatoSaluteSettimanale]
    @Environment(\.presentationMode) var presentationMode

    @State private var nuovoStato = StatoSaluteSettimanale(settimana: "", data: Date(), scariche: 0, percentualeSangue: 0, peso: 0, statoSaluteGenerale: "", tipologiaCacca: 5.0)

    var body: some View {
        InserimentoStatoSaluteView(statoSalute: $nuovoStato)
            .navigationBarItems(trailing: Button("Salva") {
                statiSalute.append(nuovoStato)
                StatoSaluteManager.shared.salva(statiSalute)
                presentationMode.wrappedValue.dismiss()
            })
    }
}

struct InserimentoStatoSaluteView: View {
    @StateObject private var locationManager = LocationManager()
    @Binding var statoSalute: StatoSaluteSettimanale
    @State private var settimana = ""
    @State private var peso = ""
    @State private var statoSaluteGenerale = ""
    @State private var tipologiaCacca: Double = 0
    @State private var scaricheSlider: Double = 0
    @State private var sangueSlider: Double = 0
    @State private var showAlert = false
    @State private var alertMessage = ""
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark
                    ? [Color.purple.opacity(0.4), Color.black]
                    : [Color(.systemTeal).opacity(0.2), Color.white]
                ),
                startPoint: .top,
                endPoint: .bottom
            ).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 25) {
                    Text("🩺 Report Settimanale")
                        .font(.largeTitle.bold())
                        .padding(.top)

                    Text("Inserisci i dati e confermali prima di salvare !!.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    Group {
                        InputField(label: "🗓️ Settimana", placeholder: "Es. Settimana 1", text: $settimana)

                        VStack(alignment: .leading) {
                            Text("🚽 Numero Scariche: \(Int(scaricheSlider))")
                            Slider(value: $scaricheSlider, in: 0...15, step: 1)
                        }.padding(.horizontal)

                        VStack(alignment: .leading) {
                            Text("🩸 Sangue nelle feci: \(descrizioneLivello(Int(sangueSlider)))")
                            Slider(value: $sangueSlider, in: 0...15, step: 1)
                        }.padding(.horizontal)

                        VStack(alignment: .leading) {
                            Text("💩 Tipologia Cacca: \(descrizioneCacca(Int(tipologiaCacca)))")
                            Text("0 = Liquida, 10 = Dura").font(.caption).foregroundColor(.gray)
                            Slider(value: $tipologiaCacca, in: 0...3, step: 1)
                        }.padding(.horizontal)

                        InputField(label: "⚖️ Peso (kg)", placeholder: "Peso attuale", text: $peso, keyboardType: .decimalPad)
                        InputField(label: "🏋🏻 Stato Generale", placeholder: "Come ti sei sentito questa settimana?", text: $statoSaluteGenerale)
                    }

                    Button(action: salvaStatoSalute) {
                        Label("Conferma i Dati", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.green]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(25)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Dati non validi"), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
        }
        .onAppear {
            locationManager.requestLocation()
            settimana = statoSalute.settimana
            peso = String(statoSalute.peso)
            statoSaluteGenerale = statoSalute.statoSaluteGenerale
            scaricheSlider = Double(statoSalute.scariche)
            sangueSlider = statoSalute.percentualeSangue
            tipologiaCacca = statoSalute.tipologiaCacca
        }
    }

    private func descrizioneLivello(_ valore: Int) -> String {
        switch valore {
        case 0: return "Niente"
        case 1...5: return "Poco"
        case 6...10: return "Moderato"
        default: return "Tanto"
        }
    }

    private func descrizioneCacca(_ valore: Int) -> String {
        switch valore {
        case 0: return "Liquida"
        case 1: return "Crema"
        case 2: return "Formata"
        default: return "Dura"
        }
    }

    private func salvaStatoSalute() {
        guard locationManager.isMonitoring else {
               alertMessage = "Attendi che venga rilevata la posizione GPS."
               showAlert = true
               return
           }
        guard let pesoDouble = Double(peso), pesoDouble > 0 else {
            alertMessage = "Peso non valido. Deve essere maggiore di 0."
            showAlert = true
            return
        }


        statoSalute = StatoSaluteSettimanale(
            settimana: settimana.isEmpty ? "Settimana 1" : settimana,
            data: Date(),
            scariche: Int(scaricheSlider),
            percentualeSangue: sangueSlider,
            peso: pesoDouble,
            statoSaluteGenerale: statoSaluteGenerale,
            tipologiaCacca: tipologiaCacca,
            latitude: locationManager.latitude,
            longitude: locationManager.longitude
        )
        
        locationManager.stopLocationRequest()
    }

}
