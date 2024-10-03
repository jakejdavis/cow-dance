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
    @Namespace private var namespace
    
    var body: some View {
        ZStack {
            NavigationStack {
                ZStack {
                    TabView(selection: $currentTab) {
                        CoverFlowView(viewModel: viewModel, namespace: namespace, selectedAlbum: $selectedAlbum)
                            .tag(0)
                        CoverFlowView(viewModel: viewModel, namespace: namespace, selectedAlbum: $selectedAlbum, isListenedView: true)
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
                           album: album
                )
                .zIndex(1)
            }
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            viewModel.loadAlbums()
        }
    }
    
    private func selectRandomAlbum() {
        let albums = currentTab == 0 ? viewModel.albums.filter { !$0.listened } : viewModel.albums.filter { $0.listened }
        if let randomAlbum = albums.randomElement() {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                selectedAlbum = randomAlbum
            }
        }
    }
}

struct AddAlbumView: View {
    enum FocusedField {
        case link
    }
    
    @Binding var spotifyLink: String
    @Namespace private var namespace
    @FocusState private var focusedField: FocusedField?
    
    @State private var album: Album?
    @ObservedObject var viewModel: SpotifyViewModel
    
    @State private var debouncedLink: String = ""
    private let debounceDelay: TimeInterval = 0.5
    @State private var cancellable: AnyCancellable?
    
    var onAdd: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                AlbumItemView(namespace: namespace, selected: .constant(false), rotation: 0, album: album)
                    .frame(width: 200, height: 200)
                
                Form {
                    HStack {
                        TextField("Paste Spotify link here", text: $spotifyLink)
                            .focused($focusedField, equals: .link)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .onChange(of: spotifyLink) { newValue in
                                debounceSpotifyLink(newValue)
                            }
                        
                        Button(action: {
                            if let link = UIPasteboard.general.string {
                                spotifyLink = link
                            }
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onAppear {
                    focusedField = .link
                }
                .padding()
                
                Button("Add Album") {
                    onAdd()
                }
                .buttonStyle(.borderedProminent)
                .disabled(album == nil)
            }
            .navigationTitle("Add New Album")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func debounceSpotifyLink(_ newValue: String) {
        cancellable?.cancel()
        
        cancellable = Just(newValue)
            .delay(for: .seconds(debounceDelay), scheduler: RunLoop.main)
            .sink { [weak viewModel] debouncedValue in
                viewModel?.fetchAlbumFromURL(debouncedValue) { fetchedAlbum in
                    self.album = fetchedAlbum
                }
            }
    }
}




struct AddButtonView: View {
    @Binding var isAddSheetPresented: Bool
    var onRandom: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 4) {
            Button {
                onRandom()
            } label: {
                Image(systemName: "dice")
                    .font(.body.weight(.bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
            }
            
            Button {
                isAddSheetPresented = true
            } label: {
                Image(systemName: "plus")
                    .font(.body.weight(.bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(.ultraThinMaterial, in: Circle())
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
