//
//  StatoSaluteManager.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 27/04/25.
//

import Foundation
import CoreData

class StatoSaluteManager {
    static let shared = StatoSaluteManager()
    private init() {}

    private var context: NSManagedObjectContext {
        CoreDataStack.shared.context
    }

    func salva(_ stati: [StatoSaluteSettimanale]) {
        for stato in stati {
            // Controlliamo se esiste già un record con lo stesso ID
            let fetchRequest: NSFetchRequest<SaluteRecord> = SaluteRecord.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", stato.id as CVarArg)
            
            if let existing = try? context.fetch(fetchRequest).first {
                // Se esiste, aggiorna i dati
                existing.settimana = stato.settimana
                existing.data = stato.data
                existing.scariche = Int16(stato.scariche)
                existing.percentualeSangue = stato.percentualeSangue
                existing.peso = stato.peso
                existing.statoSaluteGenerale = stato.statoSaluteGenerale
                existing.tipologiaCacca = stato.tipologiaCacca
                existing.latitude = stato.latitude ?? 0.0
                existing.longitude = stato.longitude ?? 0.0
            } else {
                // Se non esiste, crea un nuovo record
                let entity = SaluteRecord(context: context)
                entity.id = stato.id
                entity.settimana = stato.settimana
                entity.data = stato.data
                entity.scariche = Int16(stato.scariche)
                entity.percentualeSangue = stato.percentualeSangue
                entity.peso = stato.peso
                entity.statoSaluteGenerale = stato.statoSaluteGenerale
                entity.tipologiaCacca = stato.tipologiaCacca
                entity.latitude = stato.latitude ?? 0.0
                entity.longitude = stato.longitude ?? 0.0
            }
        }
        
        CoreDataStack.shared.saveContext()
        print("✅ Dati salvati in Core Data")
    }

    func carica() -> [StatoSaluteSettimanale] {
        let request: NSFetchRequest<SaluteRecord> = SaluteRecord.fetchRequest()
        
        do {
            let risultati = try context.fetch(request)
            return risultati.map { entity in
                StatoSaluteSettimanale(
                    id: entity.id ?? UUID(),
                    settimana: entity.settimana ?? "",
                    data: entity.data ?? Date(),
                    scariche: Int(entity.scariche),
                    percentualeSangue: entity.percentualeSangue,
                    peso: entity.peso,
                    statoSaluteGenerale: entity.statoSaluteGenerale ?? "",
                    tipologiaCacca: entity.tipologiaCacca,
                    latitude: entity.latitude,
                    longitude: entity.longitude
                )
            }
        } catch {
            print("❌ Errore nel caricamento da Core Data: \(error)")
            return []
        }
    }
    
    func elimina(_ stato: StatoSaluteSettimanale) {
        let fetchRequest: NSFetchRequest<SaluteRecord> = SaluteRecord.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", stato.id as CVarArg)
        
        do {
            let risultati = try context.fetch(fetchRequest)
            for record in risultati {
                context.delete(record)
            }
            CoreDataStack.shared.saveContext()
            print("🗑️ Record eliminato da Core Data")
        } catch {
            print("❌ Errore durante l'eliminazione da Core Data: \(error)")
        }
    }
}
