//
//  AlbumItemView.swift
//  CowDance
//
//  Created by Jake Davis on 30/09/2024.
//

import SwiftUI
import PixieCacheKit

struct AlbumItemView: View {
    var namespace: Namespace.ID
    var albumId: String
    @Binding var show: Bool
    var albumTitle: String
    var artist: String
    var albumArtURL: String
    var rotation: Double

    var body: some View {
        VStack {
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    Text(albumTitle)
                        .fontWeight(.bold)
                        .font(.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(artist)
                        .fontWeight(.bold)
                        .font(.callout)
                }
                .padding(20)
                .background(
                    // Less opaque but taller gradient overlay
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
                PixieImage(albumArtURL, key: albumArtURL)
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
        .matchedGeometryEffect(id: "\(albumId)", in: namespace)
    }
}


struct AlbumItemView_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        AlbumItemView(namespace: namespace, albumId: "loveless", show: .constant(false), albumTitle: "Loveless", artist: "My Bloody Valentine", albumArtURL: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511", rotation: 0)
    }
}
