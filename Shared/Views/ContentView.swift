//  ContentView.swift
//  Shared
//
//  Created by Macbook on 3.07.2022.
//

import SwiftUI
import SwiftUIIntrospect
import Combine


struct ContentView: View {
    @StateObject private var viewModel = SpotifyViewModel()
    @State private var selectedAlbum: Album?
    @State private var currentTab = 0
    @State private var isAddSheetPresented = false
    @State private var spotifyLink = ""
    @State private var lastHostingView: UIView!
    @State private var settingsDetent = PresentationDetent.large
    @State private var isAnimating = false
    @Namespace private var namespace
    @State private var isShowingActionSheet = false
    
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    TabView(selection: $currentTab) {
                        CoverFlowView(viewModel: viewModel, namespace: namespace, selectedAlbum: $selectedAlbum, isAnimating: $isAnimating)
                            .tag(0)
                        CoverFlowView(viewModel: viewModel, namespace: namespace, selectedAlbum: $selectedAlbum, isListenedView: true, isAnimating: $isAnimating)
                            .tag(1)
                    }
                    .ignoresSafeArea()
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                }
                .navigationTitle(currentTab == 0 ? "To Listen" : "Listened")
                .sheet(isPresented: $isAddSheetPresented) {
                    AddAlbumView(spotifyLink: $spotifyLink, viewModel: viewModel, onAdd: {
                        viewModel.addAlbumFromURL(spotifyLink)
                        spotifyLink = ""
                        isAddSheetPresented = false
                    })
                    .presentationDetents(
                        [.medium, .large],
                        selection: $settingsDetent
                    )
                }
            }
            .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18)) { navigationController in
                let bar: UINavigationBar = navigationController.navigationBar
                let hosting = UIHostingController(rootView: AddButtonView(isAddSheetPresented: $isAddSheetPresented, onRandom:{
                    selectRandomAlbum()
                }))
                
                guard let hostingView = hosting.view else { return }
                
                bar.addSubview(hostingView)
                hostingView.backgroundColor = .clear
                
                DispatchQueue.main.async {
                    lastHostingView?.removeFromSuperview()
                    lastHostingView = hostingView
                    
                    hostingView.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        hostingView.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -8),
                        hostingView.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -4)
                    ])
                }
            }
            .preferredColorScheme(.dark)
            
            if let album = selectedAlbum {
                DetailView(namespace: namespace,
                           show: Binding(
                            get: { selectedAlbum != nil },
                            set: { if !$0 { selectedAlbum = nil } }
                           ),
                           album: album, isAnimating: $isAnimating
                )
                .zIndex(1)
            }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.loadAlbums()
        }
        
        ImportExportView(isShowingActionSheet: $isShowingActionSheet,
                                    viewModel: viewModel)
    }
    
    private func selectRandomAlbum() {
        if (!isAnimating) {
            let albums = currentTab == 0 ? viewModel.albums.filter { !$0.listened } : viewModel.albums.filter { $0.listened }
            if let randomAlbum = albums.randomElement() {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isAnimating = true
                    selectedAlbum = randomAlbum
                } completion: {
                    isAnimating = false
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}
