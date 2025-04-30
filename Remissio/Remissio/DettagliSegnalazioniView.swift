//
//  DettagliSegnalazioniView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 22/03/25.
//

import SwiftUI
import MapKit

struct DettagliSegnalazioneView: View {
    var stato: StatoSaluteSettimanale

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("🗓️ Settimana: \(stato.settimana)")
                    .font(.title2.bold())
                Text("📅 Data: \(stato.data.formatted(date: .long, time: .omitted))")
                    .font(.headline)
                Divider()

                Group {
                    Text("🚽 Scariche: \(stato.scariche)")
                    Text("🩸 Percentuale sangue: \(String(format: "%.2f", stato.percentualeSangue))%")
                    Text("💩 Tipologia cacca: \(String(format: "%.1f", stato.tipologiaCacca))")
                    Text("⚖️ Peso: \(stato.peso) kg")
                    Text("🏋🏻 Stato generale: \(stato.statoSaluteGenerale)")
                }
                .font(.body)

                if let lat = stato.latitude, let lon = stato.longitude {
                    Divider()
                    Text("📍 Posizione registrata:")
                        .font(.headline)

                    Map(coordinateRegion: .constant(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )
                    ))
                    .frame(height: 250)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                }
            }
            .padding()
        }
        .navigationTitle("Dettagli Segnalazione")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DettagliSegnalazioneView_Previews: PreviewProvider {
    static var previews: some View {
        DettagliSegnalazioneView(stato: StatoSaluteSettimanale(
            id: UUID(),
            settimana: "Week 17",
            data: Date(),
            scariche: 4,
            percentualeSangue: 10,
            peso: 70,
            statoSaluteGenerale: "Discreto",
            tipologiaCacca: 3.5,
            latitude: 45.4642,
            longitude: 9.19
        ))
    }
}
