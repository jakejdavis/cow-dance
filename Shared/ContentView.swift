//  ContentView.swift
//  Shared
//
//  Created by Macbook on 3.07.2022.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = SpotifyViewModel()
    @Namespace private var namespace
    @State private var selectedAlbum: Album?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        Spacer()
                            .frame(height: geometry.size.height / 2 - 150)
                        
                        ForEach(viewModel.albums) { album in
                            GeometryReader { geo in
                                AlbumItemView(namespace: namespace,
                                              albumId: album.id,
                                              show: Binding(
                                                get: { selectedAlbum?.id == album.id },
                                                set: { _ in }
                                              ),
                                              albumTitle: album.name,
                                              artist: album.artists.first?.name ?? "",
                                              albumArtURL: album.images.first?.url ?? "")
                                .rotation3DEffect(.degrees(-2+Double(geo.frame(in: .global).minY - geometry.size.height / 2 + 150) / 16), axis: (x: 1, y: 0, z: 0))
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        selectedAlbum = album
                                    }
                                }
                            }
                            .frame(width: 300, height: 300)
                        }
                        
                        Spacer()
                            .frame(height: geometry.size.height / 2 - 150)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            if let album = selectedAlbum {
                DetailView(namespace: namespace,
                           albumId: album.id,
                           show: Binding(
                            get: { selectedAlbum != nil },
                            set: { if !$0 { selectedAlbum = nil } }
                           ),
                           albumTitle: album.name,
                           artist: album.artists.first?.name ?? "",
                           albumArtURL: album.images.first?.url ?? "")
                    .zIndex(1)
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.fetchAlbums()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
