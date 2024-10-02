import Foundation
import CoreData

struct Album: Identifiable {
    let id: String
    let name: String
    let artists: [Artist]
    let spotifyId: String
    var listened: Bool
    let image: String
    
    struct Artist {
        let name: String
    }

}

class SpotifyViewModel: ObservableObject {
    @Published var albums: [Album] = []
    private let clientId = "5bc79824bb26473891c5b93262e8439f"
    private let clientSecret = "e2e58ebc7edd494fb4540307570e7fc7"
    private var accessToken: String?
    
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "AlbumModel")
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        loadAlbums()
        fetchAccessToken()
    }
    
    func removeAlbum(_ album: Album) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", album.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let albumEntity = results.first {
                context.delete(albumEntity)
                try context.save()
                loadAlbums()
            }
        } catch {
            print("Error removing album: \(error)")
        }
    }
    
    func addAlbumFromURL(_ urlString: String) {
        guard let url = URL(string: urlString),
              let spotifyId = url.pathComponents.last else {
            print("Invalid Spotify URL")
            return
        }
        
        fetchAlbumDetails(spotifyId: spotifyId) { result in
            switch result {
            case .success(let album):
                DispatchQueue.main.async {
                    self.saveAlbum(album)
                    self.loadAlbums()
                }
            case .failure(let error):
                print("Error fetching album details: \(error)")
            }
        }
    }
    
    func markAlbumAsListened(_ album: Album) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", album.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let albumEntity = results.first {
                albumEntity.listened = true
                try context.save()
                loadAlbums()
            }
        } catch {
            print("Error marking album as listened: \(error)")
        }
    }
    
    func markAlbumAsToListen(_ album: Album) {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
        fetchRequest.predicate = NSPredicate(format: "id == %@", album.id)
        
        do {
            let results = try context.fetch(fetchRequest)
            if let albumEntity = results.first {
                albumEntity.listened = false
                try context.save()
                loadAlbums()
            }
        } catch {
            print("Error marking album as to listen: \(error)")
        }
    }
    
    private func saveAlbum(_ album: Album) {
        let context = persistentContainer.viewContext
        let albumEntity = AlbumEntity(context: context)
        albumEntity.id = album.id
        albumEntity.name = album.name
        albumEntity.spotifyId = album.spotifyId
        albumEntity.listened = album.listened
        albumEntity.image = album.image
        
        // Save artists
        for artist in album.artists {
            let artistEntity = ArtistEntity(context: context)
            artistEntity.name = artist.name
            albumEntity.addToArtists(artistEntity)
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving album: \(error)")
        }
    }
    
    private func loadAlbums() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
        
        do {
            let albumEntities = try context.fetch(fetchRequest)
            print(albumEntities.map { entity in entity.image})
            albums = albumEntities.map { entity in
                Album(
                    id: entity.id ?? "",
                    name: entity.name ?? "",
                    artists: (entity.artists?.allObjects as? [ArtistEntity])?.map { Album.Artist(name: $0.name ?? "") } ?? [],
                    spotifyId: entity.spotifyId ?? "",
                    listened: entity.listened,
                    image: entity.image ?? ""
                )
            }
        } catch {
            print("Error loading albums: \(error)")
        }
    }
    
    private func fetchAccessToken() {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let authString = "\(clientId):\(clientSecret)".data(using: .utf8)?.base64EncodedString() ?? ""
        request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        
        let body = "grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = json["access_token"] as? String {
                        self.accessToken = token
                    }
                } catch {
                    print("Error parsing access token: \(error)")
                }
            }
        }.resume()
    }
    
    private func fetchAlbumDetails(spotifyId: String, completion: @escaping (Result<Album, Error>) -> Void) {
        guard let accessToken = accessToken,
              let url = URL(string: "https://api.spotify.com/v1/albums/\(spotifyId)") else {
            completion(.failure(NSError(domain: "SpotifyViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid access token or Spotify ID"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "SpotifyViewModel", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let spotifyAlbum = try decoder.decode(SpotifyAlbum.self, from: data)
                print(spotifyAlbum.images)
                print(spotifyAlbum.images.first)
                print(spotifyAlbum.images.first?.url ?? "")
                
                let album = Album(
                    id: UUID().uuidString,
                    name: spotifyAlbum.name,
                    artists: spotifyAlbum.artists.map { Album.Artist(name: $0.name) },
                    spotifyId: spotifyAlbum.id,
                    listened: false,
                    image: spotifyAlbum.images.first?.url ?? ""
                )
                
                completion(.success(album))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct SpotifyAlbum: Codable {
    let id: String
    let name: String
    let artists: [SpotifyArtist]
    let images: [SpotifyImage]
    
    struct SpotifyArtist: Codable {
        let name: String
    }
    
    struct SpotifyImage: Codable {
        let url: String
    }
}
