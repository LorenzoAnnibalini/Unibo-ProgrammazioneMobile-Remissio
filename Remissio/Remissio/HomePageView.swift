//
//  HomePageView.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 22/03/25.
//

import SwiftUI

struct HomePageView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = SaluteViewModel()
    @StateObject private var profiloVM = ProfiloViewModel()

    //Calcolo BMI MIN
    var pesoMin: Double {
        guard let altezza = Double(profiloVM.profilo.altezza) else { return 40 }
        let h = altezza / 100
        return 18.5 * h * h
    }

    //Calcolo BMI MAX
    var pesoMax: Double {
        guard let altezza = Double(profiloVM.profilo.altezza) else { return 100 }
        let h = altezza / 100
        return 25.0 * h * h
    }

    var scoreColorSintomi: Color {
        switch viewModel.sintomiPercent {
        case 0...10: return .cyan
        case 11...20: return .green
        case 21...40: return .orange
        default: return .red
        }
    }

    var scoreColorScariche: Color {
        switch viewModel.scarichePercent {
        case 0...5: return .cyan
        case 6...20: return .green
        case 21...50: return .orange
        default: return .red
        }
    }

    var scoreColorSangue: Color {
        switch viewModel.sanguePercent {
        case 0: return .green
        case 1...20: return .orange
        default: return .red
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: colorScheme == .dark
                        ? [Color.indigo, Color.red.opacity(0.8), Color.purple]
                        : [Color.green.opacity(0.5), Color.cyan.opacity(0.4), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottom
                ).edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        HStack {
                            Text("Remissio")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                        }.padding()

                        VStack(spacing: 15) {
                            HomeCardView(title: "📘 Diario Sintomi", icon: "list.bullet.rectangle", color: .orange, destination: AnyView(DiarioSintomiView()))
                            
                            StatisticView(title: "🎯 Monitoraggio Generale", percent: .constant(viewModel.sintomiPercent), color: scoreColorSintomi)
                            
                            HomeCardView(title: "📈 Grafici Andamento", icon: "chart.xyaxis.line", color: .blue, destination: AnyView(GraficiAndamentoView(viewModel: viewModel)))

                            StatisticView(title: "🚽 Scariche", percent: .constant(viewModel.scarichePercent), color: scoreColorScariche)
                            StatisticView(title: "🩸 Sangue", percent: .constant(viewModel.sanguePercent), color: scoreColorSangue)

                            // Gauge Peso Calcolato
                            HStack(spacing: 50) {
                                Gauge(value: viewModel.pesoAttuale, in: pesoMin...pesoMax) {
                                    Text("⚖️ Peso")
                                } currentValueLabel: {
                                    Text("\(viewModel.pesoAttuale, specifier: "%.1f") kg")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .gaugeStyle(.accessoryCircular)
                                .tint(Gradient(colors: [.red, .green, .green, .red]))
                                .frame(width: 100, height: 100)
                                .scaleEffect(2)

                                Gauge(value: viewModel.pesoAttuale, in: pesoMin...pesoMax) {
                                    Text("Trend")
                                } currentValueLabel: {
                                    Text("Stabile")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                .gaugeStyle(.accessoryCircular)
                                .tint(Gradient(colors: [.indigo, .cyan, .indigo]))
                                .frame(width: 100, height: 100)
                                .scaleEffect(2)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 8)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Home")
        }
        .onAppear {
            profiloVM.loadProfilo()
        }
    }
}


// Card View (HomeCardView)
struct HomeCardView: View {
    var title: String
    var icon: String
    var color: Color
    var destination: AnyView
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Image(systemName: icon)
                    .font(.largeTitle)
                    .foregroundColor(colorScheme == .dark ? .black : .white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .clipShape(Circle())
                
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Spacer()
            }
            .padding()
            .background(colorScheme == .dark ? Color.black.opacity(0.7) : Color.white.opacity(0.8))
            .cornerRadius(12)
            .shadow(color: colorScheme == .dark ? .white.opacity(0.3) : .gray.opacity(0.3), radius: 8, x: 0, y: 4)
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
