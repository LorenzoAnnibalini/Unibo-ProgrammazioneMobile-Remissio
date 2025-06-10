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

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 45.4642, longitude: 9.19),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var hasSetRegion = false

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
                    Text("🩸 Percentuale sangue: \(String(format: "%.1f", stato.percentualeSangue))%")
                    Text("💩 Tipologia cacca: \(descrizioneCacca(Int(stato.tipologiaCacca)))")
                    Text("⚖️ Peso: \(String(format: "%.1f", stato.peso)) kg")
                    Text("🏋🏻 Stato generale: \(stato.statoSaluteGenerale)")
                }
                .font(.body)

                if let lat = stato.latitude, let lon = stato.longitude {
                    Divider()
                    Text("📍 Posizione registrata:")
                        .font(.headline)

                    Map(coordinateRegion: $region)
                        .frame(height: 250)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                }
            }
            .padding()
        }
        .navigationTitle("Dettagli Segnalazione")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasSetRegion, let lat = stato.latitude, let lon = stato.longitude {
                DispatchQueue.main.async {
                    region.center = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    hasSetRegion = true
                    print("📍 Coordinate caricate: \(lat), \(lon)")
                }
            }
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
