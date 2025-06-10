//
//  ProfiloViewModel.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 22/04/25.
//

import Foundation

struct Profilo: Codable {
    var nome: String = ""
    var cognome: String = ""
    var codiceFiscale: String = ""
    var altezza: String = ""
    var sesso: String = ""
    var eta: String = ""
    var dataDiNascita: String = ""
    var luogo: String = ""
    var residenza: String = ""
    var tipoMalattia: String = ""
    var fotoProfiloData: Data? = nil //Aggiunta foto (come dati)
}


class ProfiloViewModel: ObservableObject {
    @Published var profilo = Profilo() {
        didSet {
            saveProfilo()
        }
    }

    private let profiloKey = "profiloKey"

    init() {
        loadProfilo()
    }

    func saveProfilo() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(profilo)
            UserDefaults.standard.set(data, forKey: profiloKey)
            print("✅ Profilo salvato con successo su UserDefaults.")
        } catch {
            print("❌ Errore nel salvataggio del profilo su UserDefaults: \(error)")
        }
    }

    func loadProfilo() {
        guard let data = UserDefaults.standard.data(forKey: profiloKey) else {
            print("ℹ️ Nessun profilo trovato nei UserDefaults.")
            return
        }

        do {
            let decoder = JSONDecoder()
            let loadedProfilo = try decoder.decode(Profilo.self, from: data)
            self.profilo = loadedProfilo
            print("✅ Profilo caricato con successo da UserDefaults.")
        } catch {
            print("❌ Errore nel caricamento del profilo da UserDefaults: \(error)")
        }
    }
}
