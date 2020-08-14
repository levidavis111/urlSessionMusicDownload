//
//  SongDownload.swift
//  HalfTunes
//
//  Created by Levi Davis on 8/14/20.
//  Copyright © 2020 raywenderlich. All rights reserved.
//

import SwiftUI

class SongDownload: NSObject, ObservableObject {
    var downloadTask: URLSessionDownloadTask?
    var dowloadURL: URL?
    @Published var downloadLocation: URL?
    lazy var urlSession: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }()
    
    func fetchSongAtURL(_ item: URL) {
        dowloadURL = item
        downloadTask = urlSession.downloadTask(with: item)
        downloadTask?.resume()
    }
}

extension SongDownload: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let fileManager = FileManager.default
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first, let lastPathComponent = dowloadURL?.lastPathComponent else {return}
        let destinationURL = documentsPath.appendingPathComponent(lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: location, to: destinationURL)
            DispatchQueue.main.async {
                self.downloadLocation = destinationURL
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
}
