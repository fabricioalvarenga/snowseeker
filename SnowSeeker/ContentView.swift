//
//  ContentView.swift
//  SnowSeeker
//
//  Created by FABRICIO ALVARENGA on 17/11/22.
//

import SwiftUI

extension View {
    @ViewBuilder func phoneOnlyNavigationView() -> some View {
        if UIDevice.current.userInterfaceIdiom == .phone {
            self.navigationViewStyle(.stack)
        } else {
            self
        }
    }
}

struct ContentView: View {
    enum SortOrder: String {
        case defaultOrder = ""
        case nameOrder = "name"
        case countryOrder = "country"
    }
    
    let resorts: [Resort] = Bundle.main.decode("resorts.json")
    
    @StateObject var favorites = Favorites()
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .defaultOrder
    
    var filteredResorts: [Resort] {
        var r: [Resort]
        
        if searchText.isEmpty {
            r = resorts
        } else {
            r = resorts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        switch sortOrder {
        case .defaultOrder:
            return r
        case .nameOrder:
            return r.sorted { $0.name < $1.name }
        case .countryOrder:
            return r.sorted { $0.country < $1.country }
        }
        
    }
    
    var body: some View {
        NavigationView {
            List(filteredResorts) { resort in
                NavigationLink {
                    ResortView(resort: resort)
                } label: {
                    HStack {
                        Image(resort.country)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 25)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.black, lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading) {
                            Text(resort.name)
                                .font(.headline)
                            Text("\(resort.runs) runs")
                                .foregroundColor(.secondary)
                        }
                        
                        if favorites.contains(resort) {
                            Spacer()
                            Image(systemName: "heart.fill")
                                .accessibilityLabel("This is a favorite resort")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("Resorts")
            .toolbar {
                ToolbarItem {
                    Menu {
                        Button("Default") { sortOrder = .defaultOrder }
                        Button("Name") { sortOrder = .nameOrder }
                        Button("Country") { sortOrder = .countryOrder }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a resort")
            
            WelcomeView()
        }
        .environmentObject(favorites)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
