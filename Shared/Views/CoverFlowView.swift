import SwiftUI

struct CoverFlowView: View {
    @ObservedObject var viewModel: SpotifyViewModel
    @Namespace private var namespace
    @Binding var selectedAlbum: Album?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        Spacer()
                            .frame(height: 40)
                        
                        ForEach(viewModel.albums) { album in
                            AlbumItemRotationView(album: album,
                                          namespace: namespace,
                                          selectedAlbum: $selectedAlbum,
                                          geometryHeight: geometry.size.height)
                            .frame(width: 300, height: 300)
                        }
                        
                        Spacer()
                            .frame(height: 200)
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
    }
}

struct AlbumItemRotationView: View {
    let album: Album
    var namespace: Namespace.ID
    @Binding var selectedAlbum: Album?
    let geometryHeight: CGFloat
    @State private var isPressed: Bool = false // State to track long press

    var body: some View {
        GeometryReader { geo in
            AlbumItemView(namespace: namespace,
                          albumId: album.id,
                          show: Binding(
                            get: { selectedAlbum?.id == album.id },
                            set: { _ in }
                          ),
                          albumTitle: album.name,
                          artist: album.artists.first?.name ?? "",
                          albumArtURL: album.images.first?.url ?? "",
                          rotation: Double(geo.frame(in: .global).minY - geometryHeight / 2 + 150) / 24
            )
            
            
            .onTapGesture {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    selectedAlbum = album
                }
            }
            .onLongPressGesture(minimumDuration: 0.5, pressing: { pressing in
                // Update the isPressed state based on pressing status
                withAnimation {
                    isPressed = pressing
                }
            }, perform: {
                // Perform any action on long press completion (if needed)
            })
            
        }
    }
}

