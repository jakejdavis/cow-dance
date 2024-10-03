//
//  AlbumItemView.swift
//  CowDance
//
//  Created by Jake Davis on 30/09/2024.
//

import SwiftUI
import SkeletonUI
import PixieCacheKit

struct AlbumItemView: View {
    var namespace: Namespace.ID
    @Binding var selected: Bool
    var rotation: Double
    var album: Album?
    
    
    var body: some View {
        VStack {
            VStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text(!selected ? album?.name ?? "" : "")
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(!selected ? album?.artists.first?.name ?? "" : "")
                        .fontWeight(.bold)
                        .font(.callout)
                }
                .padding(20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.7),
                            Color.clear
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            }
            .foregroundStyle(.white)
            .background(
                PixieImage(album?.image ?? "", key: album?.image ?? "")
            )
            .mask {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .zIndex(1000)
        .rotation3DEffect(
            .degrees(rotation),
            axis: (x: 1, y: 0, z: 0)
        )
        .matchedGeometryEffect(id: album?.id ?? UUID().uuidString, in: namespace)
        .skeleton(with: album == nil,
                  shape: .rounded(.radius(30))) // Apply skeleton when album is nil
    }
}


struct AlbumItemView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    static var previews: some View {
        AlbumItemView(namespace: namespace, selected: .constant(true), rotation: 0, album: Album(id: "1", name: "Loveless", artists: [Album.Artist(name: "My Bloody Valentine")], spotifyId: "", listened: false, image: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511"))
    }
}
