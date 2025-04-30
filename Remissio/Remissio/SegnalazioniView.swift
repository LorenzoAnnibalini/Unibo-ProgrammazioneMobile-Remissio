//
//  SegnalazioniView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 27/04/25.
//

import SwiftUI
import Foundation

struct SegnalazioniView: View {
    @ObservedObject var profiloVM = ProfiloViewModel()
    @State private var statiSalute: [StatoSaluteSettimanale] = []
    @State private var selezionati: Set<UUID> = []
    @State private var emailDestinatario: String = ""
    @State private var mostraMailView = false
    @State private var emailSubject = "Aggrionamento Stato Salute MICI"
    @State private var emailBody = ""


    var body: some View {
        NavigationView {
            VStack {
                Text("📤 Seleziona le settimane")
                    .font(.title2.bold())
                    .padding()

                List(statiSalute, id: \.id, selection: $selezionati) { stato in
                    VStack(alignment: .leading) {
                        Text(stato.settimana).font(.headline)
                        Text("Scariche: \(stato.scariche), Sangue: \(String(format: "%.1f", stato.percentualeSangue))%")
                            .font(.caption)
                    }
                }
                .environment(\.editMode, .constant(.active))

                VStack(alignment: .leading, spacing: 10) {
                    Text("📧 Email Destinatario:")
                        .font(.subheadline.bold())
                    TextField("Inserisci l'email del medico", text: $emailDestinatario)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding(.horizontal)
                }
                .padding()

                Button(action: inviaEmail) {
                    Label("Invia Segnalazione", systemImage: "paperplane.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.gradient)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .padding(.horizontal)
                }
            }
            .onAppear(perform: caricaStati)
            .navigationTitle("Crea Segnalazione")
            .sheet(isPresented: $mostraMailView) {
                MailView(destinatario: emailDestinatario, subject: emailSubject, body: emailBody)
            }

        }
    }

    private func caricaStati() {
        // Usa il manager per caricare i dati
        statiSalute = StatoSaluteManager.shared.carica()
    }

    private func inviaEmail() {
        guard !emailDestinatario.isEmpty else {
            print("⚠️ Inserisci un'email valida.")
            return
        }

        let selezionatiStati = statiSalute.filter { selezionati.contains($0.id) }
        let score = calcolaScore(from: selezionatiStati)
        emailBody = generaCorpoEmail(score: score, dati: selezionatiStati)
        mostraMailView = true
    }


    private func calcolaScore(from stati: [StatoSaluteSettimanale]) -> Int {
        stati.reduce(0) { score, stato in
            score + (stato.scariche > 7 ? 1 : 0)
                  + (stato.percentualeSangue > 5 ? 1 : 0)
                  + (stato.tipologiaCacca > 2 ? 1 : 0)
        }
    }

    private func generaCorpoEmail(score: Int, dati: [StatoSaluteSettimanale]) -> String {
        var testo = "👤 Paziente: \(profiloVM.profilo.nome) \(profiloVM.profilo.cognome)\n"
        testo += "📄 Codice Fiscale: \(profiloVM.profilo.codiceFiscale)\n"
        testo += "🧬 Età: \(profiloVM.profilo.eta) - Sesso: \(profiloVM.profilo.sesso)\n"
        testo += "📍 Residenza: \(profiloVM.profilo.residenza)\n"
        testo += "🏥 Tipo Malattia: \(profiloVM.profilo.tipoMalattia)\n\n"

        testo += "🧮 Score stato salute: \(score)/\(dati.count * 3)\n\n"
        testo += "📘 Storico settimane:\n"
        for stato in dati {
            testo += "- \(stato.settimana): Scariche \(stato.scariche), Sangue \(stato.percentualeSangue)%, Peso \(stato.peso)kg, Tipologia \(stato.tipologiaCacca), Stato: \(stato.statoSaluteGenerale)\n"
        }

        return testo
    }
}

extension String {
    var urlEncoded: String {
        self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
