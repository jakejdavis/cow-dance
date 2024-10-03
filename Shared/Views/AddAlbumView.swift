//
//  AddAlbumView.swift
//  CowDance
//
//  Created by Jake Davis on 03/10/2024.
//

import SwiftUI
import Combine

struct AddAlbumView: View {
    enum FocusedField {
        case link
    }
    
    @Binding var spotifyLink: String
    @Namespace private var namespace
    @FocusState private var focusedField: FocusedField?
    
    @State private var album: Album?
    @ObservedObject var viewModel: SpotifyViewModel
    
    @State private var debouncedLink: String = ""
    private let debounceDelay: TimeInterval = 0.5
    @State private var cancellable: AnyCancellable?
    
    var onAdd: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                AlbumItemView(namespace: namespace, selected: .constant(false), rotation: 0, album: album)
                    .frame(width: 200, height: 200)
                
                Form {
                    HStack {
                        TextField("Paste Spotify link here", text: $spotifyLink)
                            .focused($focusedField, equals: .link)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .onChange(of: spotifyLink) { newValue in
                                debounceSpotifyLink(newValue)
                            }
                        
                        Button(action: {
                            if let link = UIPasteboard.general.string {
                                spotifyLink = link
                            }
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .onAppear {
                    focusedField = .link
                }
                .padding([.horizontal])
                
                Button("Add Album") {
                    onAdd()
                }
                .buttonStyle(.borderedProminent)
                .disabled(album == nil)
                .padding()
            }
            .navigationTitle("Add New Album")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func debounceSpotifyLink(_ newValue: String) {
        cancellable?.cancel()
        
        cancellable = Just(newValue)
            .delay(for: .seconds(debounceDelay), scheduler: RunLoop.main)
            .sink { [weak viewModel] debouncedValue in
                viewModel?.fetchAlbumFromURL(debouncedValue) { fetchedAlbum in
                    self.album = fetchedAlbum
                }
            }
    }
}

struct AddAlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AddAlbumView(spotifyLink: .constant(""), viewModel: SpotifyViewModel(preloadData: false), onAdd: {})
    }
}
