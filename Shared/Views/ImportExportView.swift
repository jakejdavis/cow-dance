//
//  ImportExportView.swift
//  CowDance
//
//  Created by Jake Davis on 03/10/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportExportView: View {
    @Binding var isShowingActionSheet: Bool
    @State var isImporting: Bool = false
    @State var isExporting: Bool = false
    @ObservedObject var viewModel: SpotifyViewModel
    
    var body: some View {
        VStack {
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
            isShowingActionSheet = true
        }
        .actionSheet(isPresented: $isShowingActionSheet) {
            ActionSheet(title: Text("Import/Export Albums"), buttons: [
                .default(Text("Import Albums")) {
                    isImporting = true
                },
                .default(Text("Export Albums")) {
                    isExporting = true
                },
                .cancel()
            ])
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            do {
                let selectedFile: URL = try result.get().first!
                if viewModel.importAlbums(from: selectedFile) {
                    print("Import successful")
                } else {
                    print("Import failed")
                }
            } catch {
                print("Error importing file: \(error.localizedDescription)")
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: JSONFile(initialText: ""),
            contentType: UTType.json,
            defaultFilename: "cow.dance.export.\(Date().timeIntervalSince1970).json"
        ) { result in
            do {
                let url = try result.get()
                if viewModel.exportAlbums(to: url) {
                    print("Export successful")
                } else {
                    print("Export failed")
                }
            } catch {
                print("Error exporting file: \(error.localizedDescription)")
            }
        }
    }
}



// Helper struct for file exporting
struct JSONFile: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    
    var text = ""
    
    init(initialText: String = "") {
        text = initialText
    }
    
    init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            text = String(decoding: data, as: UTF8.self)
        }
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return FileWrapper(regularFileWithContents: data)
    }
}
