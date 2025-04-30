//
//  SaluteViewModel.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 24/04/25.
//

import SwiftUI

class SaluteViewModel: ObservableObject {
    @Published var statiSalute: [StatoSaluteSettimanale] = []
    
    // Valori Attuali
    var pesoAttuale: Double {
        statiSalute.last?.peso ?? 70.0
    }

    var scarichePercent: Double {
        guard let last = statiSalute.last else { return 0 }
        return min((Double(last.scariche) / 20.0) * 100.0, 100.0)
    }

    var sanguePercent: Double {
        guard let last = statiSalute.last else { return 0 }
        return min(last.percentualeSangue, 100)
    }

    var tipologiaCacca: Double {
        return statiSalute.last?.tipologiaCacca ?? 1
    }

    // Calcolo Sintomi
    var sintomiPercent: Double {
        let profiloVM = ProfiloViewModel()
        let altezzaCM = Double(profiloVM.profilo.altezza) ?? 170
        let altezzaM = altezzaCM / 100
        let bmi = pesoAttuale / (altezzaM * altezzaM)
        let bmiScore = max(0, min(100, 100 - abs(bmi - 22) * 10)) // ideale attorno a 22

        let scaricheScore = scarichePercent
        let sangueScore = sanguePercent
        let tipologiaScore = (2 - tipologiaCacca) * 50 // liquida = peggio

        let media = (bmiScore + scaricheScore + sangueScore + tipologiaScore) / 4
        return min(media, 100)
    }

    // Inizializzazione e Caricamento Dati
    init() {
        caricaDaFile()
    }

    private func caricaDaFile() {
        // Usa il manager per caricare i dati
        statiSalute = StatoSaluteManager.shared.carica()
    }

    // Metodo per salvare gli stati di salute
    func salvaStatiSalute() {
        // Usa il manager per salvare i dati
        StatoSaluteManager.shared.salva(statiSalute)
    }
}
