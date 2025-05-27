//
//  DiarioSintomiView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 24/04/25.
//

import SwiftUI
import MapKit

struct DiarioSintomiView: View {
    @StateObject private var locationManager = LocationManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var statiSalute: [StatoSaluteSettimanale] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark
                        ? [Color.indigo, Color.red.opacity(0.8), Color.purple]
                        : [Color.green.opacity(0.5), Color.cyan.opacity(0.4), Color.white]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                List {
                    ForEach(statiSalute) { stato in
                        NavigationLink(destination: DettagliSegnalazioneView(stato: stato)) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("🗓️ \(stato.settimana)").font(.title3.bold()).foregroundColor(.primary)
                                Divider().padding(.vertical, 2)
                                Text("🚽 Scariche: \(stato.scariche)").font(.subheadline)
                                Text("🩸 Sangue: \(String(format: "%.2f", stato.percentualeSangue))%").font(.subheadline)
                                Text("💩 Tipologia: \(String(format: "%.1f", stato.tipologiaCacca))").font(.subheadline)
                                Text("⚖️ Peso: \(stato.peso) kg").font(.subheadline)
                                Text("🏋🏻 Stato: \(stato.statoSaluteGenerale)").font(.subheadline)
                            }
                            .padding()
                            .background(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        }
                    }
                    .onDelete(perform: eliminaStatoSalute)
                }
                .listStyle(PlainListStyle())
                .navigationTitle("📘 Diario Sintomi")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    NavigationLink(destination: InserimentoStatoSaluteViewWrapper(statiSalute: $statiSalute)) {
                        Label("Aggiungi", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .onAppear {
            statiSalute = StatoSaluteManager.shared.carica()
        }
    }

    private func eliminaStatoSalute(at offsets: IndexSet) {
        let statiDaEliminare = offsets.map { statiSalute[$0] }
        for stato in statiDaEliminare {
            StatoSaluteManager.shared.elimina(stato)
        }
        statiSalute.remove(atOffsets: offsets)
    }
}


struct DiarioSintomiView_Previews: PreviewProvider {
    static var previews: some View {
        DiarioSintomiView()
    }
}
