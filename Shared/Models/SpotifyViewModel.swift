import Foundation
import CoreData

struct Album: Identifiable, Codable {
    let id: String
    let name: String
    let artists: [Artist]
    let spotifyId: String
    var listened: Bool
    var addedOn: Date = Date()
    var listenedOn: Date?
    let image: String
    
    struct Artist: Codable {
        let name: String
    }
    
}

class SpotifyViewModel: ObservableObject {
    @Published var albums: [Album] = []
    private let clientId = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_ID") as? String ?? ""
    private let clientSecret = Bundle.main.object(forInfoDictionaryKey: "SPOTIFY_CLIENT_SECRET") as? String ?? ""
    
    private var accessToken: String?
    
    private let persistentContainer: NSPersistentContainer
    
    init(preloadData: Bool = true, completion: (() -> Void)? = nil) {
        let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dance.cow.tracker.shared")!
        let storeURL = groupURL.appendingPathComponent("AlbumModel.sqlite")
        
        let description = NSPersistentStoreDescription(url: storeURL)
        persistentContainer = NSPersistentContainer(name: "AlbumModel")
        persistentContainer.persistentStoreDescriptions = [description]
        
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        if preloadData {
            loadAlbums()
            fetchAccessToken(completion: completion)
        }
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
    
    func fetchAlbumFromURL(_ urlString: String, completion: @escaping (Album?) -> Void) {
        guard let url = URL(string: urlString),
              let spotifyId = url.pathComponents.last else {
            print("Invalid Spotify URL")
            completion(nil)
            return
        }
        
        fetchAlbumDetails(spotifyId: spotifyId) { result in
            switch result {
            case .success(let album):
                completion(album)
            case .failure(let error):
                print("Error fetching album details: \(error)")
                completion(nil)
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
                albumEntity.listenedOn = Date()
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
    
    func loadAlbums() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<AlbumEntity>(entityName: "AlbumEntity")
        
        do {
            let albumEntities = try context.fetch(fetchRequest)
            albums = albumEntities.map { entity in
                Album(
                    id: entity.id ?? "",
                    name: entity.name ?? "",
                    artists: (entity.artists?.allObjects as? [ArtistEntity])?.map { Album.Artist(name: $0.name ?? "") } ?? [],
                    spotifyId: entity.spotifyId ?? "",
                    listened: entity.listened,
                    addedOn: entity.addedOn ?? Date(),
                    listenedOn: entity.listenedOn,
                    image: entity.image ?? ""
                )
            }
        } catch {
            print("Error loading albums: \(error)")
        }
    }
    
    func fetchAccessToken(completion: (() -> Void)? = nil) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let authString = "\(String(describing: clientId)):\(String(describing: clientSecret))".data(using: .utf8)?.base64EncodedString() ?? ""
        request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        
        let body = "grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = json["access_token"] as? String {
                        self.accessToken = token
                        completion?()
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
                
                let album = Album(
                    id: UUID().uuidString,
                    name: spotifyAlbum.name,
                    artists: spotifyAlbum.artists.map { Album.Artist(name: $0.name) },
                    spotifyId: spotifyAlbum.id,
                    listened: false,
                    addedOn: Date(),
                    listenedOn: nil,
                    image: spotifyAlbum.images.first?.url ?? ""
                )
                
                completion(.success(album))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func exportAlbums(to url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else {
            print("Error: Couldn't access security-scoped resource.")
            return false
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(albums)
            try data.write(to: url)
            return true
        } catch {
            print("Error exporting albums: \(error)")
            return false
        }
    }

    
    func importAlbums(from url: URL) -> Bool {
        guard url.startAccessingSecurityScopedResource() else {
            print("Error: Couldn't access security-scoped resource.")
            return false
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importedAlbums = try decoder.decode([Album].self, from: data)
            
            // Clear existing albums in Core Data
            let context = persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "AlbumEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            try context.execute(deleteRequest)
            try context.save()
            
            // Save imported albums to Core Data
            for album in importedAlbums {
                saveAlbum(album)
            }
            
            // Reload albums
            loadAlbums()
            
            return true
        } catch {
            print("Error importing albums: \(error)")
            return false
        }
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
