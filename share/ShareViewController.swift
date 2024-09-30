//
//  ShareViewController.swift
//  share
//
//  Created by Jake Davis on 30/09/2024.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {

    // Regular expression pattern to validate Spotify URLs
    let spotifyUrlPattern = "https?://(open|play)\\.spotify\\.com/.*"

    override func isContentValid() -> Bool {
        // Ensure the contentText contains a valid Spotify URL
        if let content = contentText {
            return isValidSpotifyLink(content)
        }
        return false
    }

    override func didSelectPost() {
        // Handle posting the content
        // Here, you can process the Spotify link if necessary

        // Complete the request
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // Add configuration items if needed
        return []
    }

    // Helper method to validate if the text is a valid Spotify link
    private func isValidSpotifyLink(_ text: String) -> Bool {
        let regex = try? NSRegularExpression(pattern: spotifyUrlPattern, options: [])
        let range = NSRange(location: 0, length: text.utf16.count)
        return regex?.firstMatch(in: text, options: [], range: range) != nil
    }
}
