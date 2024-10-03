import SwiftUI

struct CoverFlowView: View {
    @ObservedObject var viewModel: SpotifyViewModel
    var namespace: Namespace.ID
    @Binding var selectedAlbum: Album?
    var isListenedView: Bool = false
    
    private func filteredAlbums() -> [Album] {
        let filtered = viewModel.albums.filter { album in
            isListenedView ? album.listened : !album.listened
        }
        
        // Sort by addedOn ascending and listenedOn descending for listened albums
        return filtered.sorted { a, b in
            if isListenedView {
                if let aListenedOn = a.listenedOn, let bListenedOn = b.listenedOn {
                    return aListenedOn > bListenedOn // Descending order for listenedOn
                }
            }
            return a.addedOn < b.addedOn // Ascending order for addedOn
        }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        Spacer()
                            .frame(height: 40)
                        
                        ForEach(filteredAlbums()) { album in
                            AlbumItemRotationView(album: album,
                                                  namespace: namespace,
                                                  selectedAlbum: $selectedAlbum,
                                                  geometryHeight: geometry.size.height,
                                                  toggleListened: {
                                if album.listened {
                                    viewModel.markAlbumAsToListen(album)
                                } else {
                                    viewModel.markAlbumAsListened(album)
                                }
                            },
                                                  remove: {
                                viewModel.removeAlbum(album)
                            })
                            .frame(width: 300, height: 300)
                        }
                        
                        Spacer()
                            .frame(height: 200)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct AlbumItemRotationView: View {
    let album: Album
    var namespace: Namespace.ID
    @Binding var selectedAlbum: Album?
    let geometryHeight: CGFloat
    
    var toggleListened: () -> Void
    var remove: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            AlbumItemView(namespace: namespace,
                          selected: Binding(
                            get: { selectedAlbum?.id == album.id },
                            set: { _ in }
                          ),
                          rotation: Double(geo.frame(in: .global).minY - geometryHeight / 2 + 150) / 24,
                          album: album
            )
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedAlbum = album
                }
            }
            .contextMenu {
                Button {
                    toggleListened()
                } label: {
                    if album.listened {
                        Label("Mark as To Listen", systemImage: "arrow.uturn.backward.circle")
                    } else {
                        Label("Mark Listened", systemImage: "checkmark.circle.fill")
                    }
                }
                
                Button {
                    remove()
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            }
        }
    }
}
