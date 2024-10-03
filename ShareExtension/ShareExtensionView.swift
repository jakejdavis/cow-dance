//
//  ShareExtensionView.swift
//  ShareExtension
//
//  Created by Jake Davis on 02/10/2024.
//

import Foundation
import SwiftUI

struct ShareExtensionView: View {
    @State private var spotifyUrl: String
    @StateObject private var viewModel = SpotifyViewModel(preloadData: false)
    @State private var album: Album?
    @Namespace private var namespace
    
    
    
    var close: () -> Void
    
    init(spotifyUrl: String, close: @escaping () -> Void) {
        self.spotifyUrl = spotifyUrl
        self.close = close
    }
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 20){
                AlbumItemView(namespace: namespace, selected: .constant(false), rotation: 0, album: album)
                    .frame(width: 200, height: 200)
                
                Button {
                    viewModel.addAlbumFromURL(spotifyUrl)
                    close()
                } label: {
                    Text("Add")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Add Album")
            .toolbar {
                Button("Cancel") {
                    close()
                }
            }
        }.onAppear(perform: {
            viewModel.fetchAccessToken() {
                viewModel.fetchAlbumFromURL(spotifyUrl) { fetchedAlbum in
                    self.album = fetchedAlbum
                }
            }
        })
    }
}
