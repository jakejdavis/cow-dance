import SwiftUI

struct DetailView: View {
    var namespace: Namespace.ID
    var albumId: String
    @Binding var show: Bool
    var albumTitle: String
    var artist: String
    var albumArtURL: String
    
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea().opacity(opacity)
            
            ScrollView {
                VStack {
                    show ? AlbumItemView(namespace: namespace,
                                  albumId: albumId, show: $show, albumTitle: albumTitle, artist: artist, albumArtURL: albumArtURL, rotation: Double(0))
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.2)) {
                                opacity = 0
                            } completion: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    show.toggle()
                                }
                            }
                            
                            
                        } : nil
                    
                    VStack {
                        Text("Album Details")
                            .fontWeight(.bold)
                            .font(.title)
                            .padding()
                        
                        Text(albumTitle)
                            .font(.headline)
                        
                        Text(artist)
                            .font(.subheadline)
                    }.opacity(opacity)
                }
            }
    
            
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 1
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        DetailView(namespace: namespace, albumId: "1", show: .constant(true), albumTitle: "Loveless", artist: "My Bloody Valentine", albumArtURL: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511")
    }
}
