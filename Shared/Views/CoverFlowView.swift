import SwiftUI

struct CoverFlowView: View {
    @ObservedObject var viewModel: SpotifyViewModel
    var namespace: Namespace.ID
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
        
        }
    }
}

struct AlbumItemRotationView: View {
    let album: Album
    var namespace: Namespace.ID
    @Binding var selectedAlbum: Album?
    let geometryHeight: CGFloat

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
            .contextMenu {
                   Button {
                       print("Mark Listened")
                   } label: {
                       Label("Mark Listened", systemImage: "checkmark.circle.fill")
                   }

                   Button {
                       print("Remove")
                   } label: {
                       Label("Remove", systemImage: "trash")
                   }
               }
            
        }
    }
}

