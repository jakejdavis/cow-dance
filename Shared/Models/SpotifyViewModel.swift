//
//  SpotifyViewModel.swift
//  CowDance
//
//  Created by Jake Davis on 30/09/2024.
//

import Foundation

struct Album: Identifiable, Decodable {
    let id: String
    let name: String
    let artists: [Artist]
    let images: [Image]
    
    struct Artist: Decodable {
        let name: String
    }
    
    struct Image: Decodable {
        let url: String
    }
}

class SpotifyViewModel: ObservableObject {
    @Published var albums: [Album] = []
    
    func removeAlbum(_ album: Album) {
        albums.removeAll { $0.id == album.id }
    }
    
    func fetchAlbums(completed: Bool = false) {
        // Simulated API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.albums = [
                Album(id: completed ? "completed_1" : "1", name: "Loveless", artists: [Album.Artist(name: "My Bloody Valentine")], images: [Album.Image(url: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511")]),
                Album(id: completed ? "completed_2" : "2", name: "OK Computer", artists: [Album.Artist(name: "Radiohead")], images: [Album.Image(url: "https://i.scdn.co/image/ab67616d0000b273c8b444df094279e70d0ed856")]),
                Album(id: completed ? "completed_3" : "3", name: "Kid A", artists: [Album.Artist(name: "Radiohead")], images: [Album.Image(url: "https://i.scdn.co/image/ab67616d00001e026c7112082b63beefffe40151")])
            ]
        }
    }

}
