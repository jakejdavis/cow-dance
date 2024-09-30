//
//  MatchedGeometryEffectApp.swift
//  Shared
//
//  Created by Macbook on 3.07.2022.
//

import SwiftUI
import PixieCacheKit

@main
struct CowDanceApp: App {
    init() {
        PixieCacheKit.configure(directoryName: "CowDanceCache", imageFormat: .jpeg)
        PixieCacheKit.configure(memoryLimit: 100)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
