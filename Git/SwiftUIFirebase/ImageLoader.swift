//
//  ImageLoader.swift
//  SwiftUIFirebase
//
//  Created by MAC215 on 05/04/21.
//

import SwiftUI
import Combine
import Foundation
import Firebase

fileprivate let storageRef = Firebase.Storage.storage().reference()
fileprivate let storage = Firebase.Storage.storage()

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private let urlStr: String
    
    private var cancellable: AnyCancellable?
    
    init(urlStr: String) {
        self.urlStr = urlStr
    }
    
    func load() {
        if !urlStr.isEmpty  {
            storageRef.child(urlStr).downloadURL { [self] (finalURL, error) in
                guard let url = finalURL else { return }
                let imageRef = storage.reference(forURL: url.absoluteString)
                imageRef.getData(maxSize: 10 * 1024 * 1024) { [self] data, error in
                    if let error = error {
                        print("error downloading \(error)")
                    } else {
                        if let finalImage = UIImage(data: data!) {
                            self.image = finalImage
                        } else {
                            print("no image")
                        }
                    }
                }
            }
        }
    }
    
    func cancel() {
        
    }
    
    deinit {
        cancel()
    }
}

struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    
    init(urlStr: String, @ViewBuilder placeholder: () -> Placeholder) {
        self.placeholder = placeholder()
        _loader = StateObject(wrappedValue: ImageLoader(urlStr: urlStr))
    }

    var body: some View {
        content
            .onAppear(perform: loader.load)
    }

    private var content: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
            } else {
                placeholder
            }
        }
    }
}
