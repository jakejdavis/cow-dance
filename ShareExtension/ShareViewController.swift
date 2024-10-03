import UIKit
import UniformTypeIdentifiers
import SwiftUI

class ShareViewController: UIViewController {
    var url: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            close()
            return
        }
        
        let urlDataType = UTType.url.identifier
        
        for attachment in extensionItem.attachments ?? [] {
            extractUrl(from: attachment, typeIdentifier: urlDataType) { extractedUrl in
                if let url = extractedUrl {
                    self.url = url
                    DispatchQueue.main.async {
                        self.presentShareExtensionView(with: url)
                    }
                }
            }
        }
    }
    
    
    private func extractUrl(from itemProvider: NSItemProvider, typeIdentifier: String, completion: @escaping (String?) -> Void) {
        if itemProvider.hasItemConformingToTypeIdentifier(typeIdentifier) {
            itemProvider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { (item, error) in
                if let urlItem = item as? URL {
                    completion(urlItem.absoluteString)
                } else {
                    completion(nil)
                }
            }
        } else {
            completion(nil)
        }
    }
    
    private func presentShareExtensionView(with spotifyUrl: String) {
        let contentView = UIHostingController(rootView: ShareExtensionView(spotifyUrl: spotifyUrl, close: close))
        
        contentView.preferredContentSize = CGSize(width: 300, height: 400)
        contentView.modalPresentationStyle = .formSheet
        
        if let sheet = contentView.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(contentView, animated: true, completion: nil)
    }
    
    func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
