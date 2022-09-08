//
//  LogEncounterStagingView.swift
//  Birdie
//
//  Created by Daniel Jilg on 08.09.22.
//

import SwiftUI

struct LogEncounterStagingView: View {
    @State var encounterDate: Date = .init()
    @State var encounterBirds: [Bird] = []
    @State var encounterLocation: String = ""
    
    @Namespace var namespace
    
    @State var query = ""
    @FocusState var queryFieldIsFocused: Bool
    
    @Environment(\.presentationMode) var presentation
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Bird.canonicalName, ascending: true)],
        animation: .default
    )
    private var filteredBirds: FetchedResults<Bird>
    
    var body: some View {
        NavigationView {
            Form {
                Section("Birds encountered") {
                    
                        ForEach(encounterBirds) { bird in
                            Text(bird.canonicalName ?? "BIRD")
                        }
                    
                    
                    TextField("Add Bird", text: $query)
                        .submitLabel(.done)
                        .focused($queryFieldIsFocused)
                        .onChange(of: query, perform: updateQuery)
                    
                    if queryFieldIsFocused {
                        ForEach(filteredBirds, id: \.self) { bird in
                            Button(bird.canonicalName ?? "BIRD") {
                                withAnimation {
                                    addToEncounter(bird: bird)
                                }
                            }
                        }
                    }
                }
                
                .contentTransition(.interpolate)
            }
            .navigationTitle("Add Encounter")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: cancel)
                }
            }
            .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.queryFieldIsFocused = true
              }
            }
        }
    }
    
    func updateQuery(value: String) {
        filteredBirds.nsPredicate = query.isEmpty
            ? nil
            : NSPredicate(format: "canonicalName CONTAINS[cd] %@", value.lowercased())
    }
    
    func addToEncounter(bird: Bird) {
        query = ""
        queryFieldIsFocused = false
        encounterBirds.append(bird)
        
    }
    
    func save() {
        for bird in encounterBirds {
            let encounter = Encounter(context: viewContext)
            encounter.timestamp = encounterDate
            encounter.location = encounterLocation
            encounter.bird = bird
        }
        
        try? viewContext.save()
        encounterBirds = []
        self.presentation.wrappedValue.dismiss()
    }
    
    func cancel() {
        self.presentation.wrappedValue.dismiss()
    }
}

struct LogEncounterStagingView_Previews: PreviewProvider {
    static var previews: some View {
        LogEncounterStagingView()
    }
}
