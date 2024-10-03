import SwiftUI

struct DetailView: View {
    var namespace: Namespace.ID
    @Binding var show: Bool
    var album: Album
    
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea().opacity(opacity)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    show ? AlbumItemView(namespace: namespace, selected: $show, rotation: Double(0), album: album)
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            withAnimation(.easeOut(duration: 0.1)) {
                                opacity = 0
                            } completion: {
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                    show.toggle()
                                }
                            }
                        } : nil
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text(album.name)
                            .fontWeight(.bold)
                            .font(.largeTitle)
                        
                        Text(album.artists.map { $0.name }.joined(separator: ", "))
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Text("Added on: \(formattedDate(album.addedOn))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        if let listenedOn = album.listenedOn {
                            Text("Listened on: \(formattedDate(listenedOn))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        
                        Divider().padding([.top], 20)
                        
                        //
                        //                        CheckboxFieldView(text: album.listened ? "Listened" : "Not listened yet", checked: album.listened, action: {
                        //                                
                        //                        })
                        
                        VStack(alignment: .leading) {
                            Link("Open in Spotify", destination: URL(string: "spotify://album/\(album.spotifyId)")!)
                                .font(.headline)
                                .foregroundColor(.green)
                        }.padding([.top], 10)
                    }
                    .opacity(opacity)
                    .padding()
                }
            }
        }
        
        .onAppear {
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 1
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

struct DetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        DetailView(namespace: namespace, show: .constant(true), album: Album(id: "1", name: "Loveless", artists: [Album.Artist(name: "My Bloody Valentine")], spotifyId: "", listened: false, image: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511"))
    }
}
