//
//  GraficoAndamentoView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 23/04/25.
//

import SwiftUI
import Charts

struct GraficiAndamentoView: View {
    @ObservedObject var viewModel: SaluteViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Andamento nel tempo")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)

                if viewModel.statiSalute.isEmpty {
                    Text("Nessun dato disponibile")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    Group {
                        ChartSection(title: "Peso (kg)", field: \.peso, color: .green)
                        ChartSection(title: "Scariche", field: { Double($0.scariche) }, color: .orange)
                        ChartSection(title: "Sangue (%)", field: \.percentualeSangue, color: .red)
                        ChartSection(title: "Tipologia Feci", field: \.tipologiaCacca, color: .purple)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Grafici")
    }

    //Singolo grafico
    @ViewBuilder
    private func ChartSection(title: String, field: @escaping (StatoSaluteSettimanale) -> Double, color: Color) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            Chart {
                ForEach(viewModel.statiSalute) { stato in
                    LineMark(
                        x: .value("Data", stato.data),
                        y: .value("Valore", field(stato))
                    )
                    .foregroundStyle(color)
                    .symbol(Circle())
                }
            }
            .frame(height: 200)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 4)
        }
    }
}
