//  ContentView.swift
//  Shared
//
//  Created by Macbook on 3.07.2022.
//

import SwiftUI
import SwiftUIIntrospect

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
                    AddAlbumView(spotifyLink: $spotifyLink, onAdd: {
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
                let hosting = UIHostingController(rootView: AddButtonView(isAddSheetPresented: $isAddSheetPresented))
                                
                guard let hostingView = hosting.view else { return }
                
                bar.addSubview(hostingView)      
                hostingView.backgroundColor = .clear
                
                DispatchQueue.main.async {
                    lastHostingView?.removeFromSuperview()
                    lastHostingView = hostingView
                    
                    hostingView.translatesAutoresizingMaskIntoConstraints = false
                    
                    NSLayoutConstraint.activate([
                        hostingView.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -8),
                        hostingView.bottomAnchor.constraint(equalTo: bar.bottomAnchor, constant: -4),
                        hostingView.heightAnchor.constraint(equalToConstant: 44),
                        hostingView.widthAnchor.constraint(equalToConstant: 44)
                    ])
                }
            }
            .preferredColorScheme(.dark)
            
            if let album = selectedAlbum {
                DetailView(namespace: namespace,
                           albumId: album.id,
                           show: Binding(
                            get: { selectedAlbum != nil },
                            set: { if !$0 { selectedAlbum = nil } }
                           ),
                           albumTitle: album.name,
                           artist: album.artists.first?.name ?? "",
                           albumArtURL: album.image)
                    .zIndex(1)
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
    
    var onAdd: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                AlbumItemView(namespace: namespace, albumId: "loveless", show: .constant(false), albumTitle: "Loveless", artist: "My Bloody Valentine", albumArtURL: "https://i.scdn.co/image/ab67616d0000b2730ede770070357575bc050511", rotation: 0)
                    .frame(width: 200, height: 200)
                
                Form {
                    TextField("Paste Spotify link here", text: $spotifyLink) .focused($focusedField, equals: .link)  .keyboardType(.URL)
                        .textContentType(.URL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    

                        Button("Add Album") {
                            onAdd()
                        }
                        .disabled(spotifyLink.isEmpty)
                    
                }
                .onAppear {
                    focusedField = .link
                }
                .padding()
                   
            } .navigationTitle("Add New Album")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}






struct AddButtonView: View {
    @Binding var isAddSheetPresented: Bool
    
    var body: some View {
        Button {
            isAddSheetPresented = true
        } label: {
            Image(systemName: "plus")
                .font(.body.weight(.bold))
                .foregroundColor(.white)
                .padding(8)
                .background(.ultraThinMaterial, in: Circle())
        }.padding([.trailing], 16).offset(x: 0, y: -4)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
