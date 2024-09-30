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

    var body: some View {
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
        }.matchedGeometryEffect(id: "\(albumId)_text", in: namespace)
        .foregroundStyle(.white)
        .background(
            PixieImage(albumArtURL, key: albumArtURL)
                .matchedGeometryEffect(id: "\(albumId)_image", in: namespace)
        )
        .mask {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .matchedGeometryEffect(id: "\(albumId)_mask", in: namespace)
        }
        .zIndex(1000)
        .aspectRatio(1, contentMode: .fit)
    }
}


struct AlbumItemView_Previews: PreviewProvider {
    @Namespace static var namespace

    static var previews: some View {
        AlbumItemView(namespace: namespace, albumId: "loveless", show: .constant(false), albumTitle: "Loveless", artist: "My Bloody Valentine", albumArtURL: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511")
    }
}
