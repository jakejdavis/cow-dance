//
//  DetailView.swift
//  MatchedGeometryEffect
//
//  Created by Macbook on 3.07.2022.
//

import SwiftUI

struct DetailView: View {
    var namespace: Namespace.ID
    var albumId: String
    @Binding var show: Bool
    var albumTitle: String
    var artist: String
    var albumArtURL: String
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    AlbumItemView(namespace: namespace,
                                  albumId: albumId, show: $show, albumTitle: albumTitle, artist: artist, albumArtURL: albumArtURL)
                        .aspectRatio(1, contentMode: .fit)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                show.toggle()
                            }
                        }.ignoresSafeArea()
                    
                    Text("Album Details")
                        .fontWeight(.bold)
                        .font(.title)
                        .padding()

                }.ignoresSafeArea()
            }.ignoresSafeArea()
            
            Button {
               withAnimation(.spring(response: 0.5, dampingFraction: 0.7)){
                   show.toggle()
               }
           } label: {
               Image(systemName: "xmark")
                   .font(.body.weight(.bold))
                   .foregroundColor(.white)
                   .padding(8)
                   .background(.ultraThinMaterial, in: Circle())
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
           .padding(.horizontal,20)
           .padding(.vertical,40)
           .ignoresSafeArea()
        }.ignoresSafeArea()
            .background(Color.black.ignoresSafeArea())
    }
}


struct DetailView_Previews: PreviewProvider {
    @Namespace static var namespace
    static var previews: some View {
        DetailView(namespace: namespace, albumId: "1", show: .constant(true),albumTitle: "Loveless", artist: "My Bloody Valentine", albumArtURL: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511")
    }
}
