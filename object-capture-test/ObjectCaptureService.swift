//
//  ObjectCaptureService.swift
//  object-capture-test
//
//  Created by Sabrina Bea on 3/17/22.
//

import AVFoundation
import Combine

class ObjectCaptureService {
    var id = UUID() // not used but lets us avoid an optional
    var progress = CurrentValueSubject<Int, Never>(0)
    var start = PassthroughSubject<Void, Never>()
    var complete = PassthroughSubject<Void, Never>()
    var error = PassthroughSubject<Void, Never>()
    var processingComplete = PassthroughSubject<Void, Never>()
    var lastRequestTime: Double = 0
    let minRequestDistance: Double = 5
    let baseUrl = ProcessInfo.processInfo.environment["SVC_BASE_URL"] ?? "192.168.4.44"
    let scheme = ProcessInfo.processInfo.environment["SVC_SCHEME"] ?? "http"
    let wsScheme: String = ProcessInfo.processInfo.environment["SVC_SCHEME"] == "https" ? "wss" : "ws"
    let port: Int = {
        guard let str = ProcessInfo.processInfo.environment["SVC_PORT"] else {
            return nil
        }
        return Int(str)
    }() ?? 8080
    
    var resultUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(id.uuidString).usdz")
    }
    
    public func sendDepthImages(_ images: [Data]) {
        let requestTime = CACurrentMediaTime();
        if requestTime - lastRequestTime < minRequestDistance {
            return
        }
        lastRequestTime = requestTime
        progress.send(0)
        
        var data = Data()
        
        for imageData in images {
            data.append(imageData)
        }
        
        var urlComps = URLComponents()
        urlComps.scheme = scheme
        urlComps.host = baseUrl
        urlComps.port = port
        urlComps.path = "/upload"
        guard let url = urlComps.url else { return }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpShouldHandleCookies = false
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(filePathKey: "files[]", images: images, boundary: boundary)
        request.timeoutInterval = 99999
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, let data = data, (200...299).contains(response.statusCode) else {
                print("Failed to Upload Photos")
                return
            }
            guard let idString = String(data: data, encoding: .utf8), let responseId = UUID(uuidString: idString) else {
                print("Failed to Parse Request ID")
                return
            }
            self.id = responseId
            self.start.send()
            self.openProgressConnection()
        }
        
        task.resume()
    }
    
    private func createBody(with params: [String: String]? = nil, filePathKey: String, images: [Data], boundary: String) -> Data {
        var body = Data()
        
        if let params = params {
            for (key, value) in params {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for (index, image) in images.enumerated() {
            let filename = "\(id.uuidString)-\(index).HEIC"
            let data = image
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: image/heic\r\n\r\n")
            body.append(data)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    private func openProgressConnection() {
        var urlComps = URLComponents()
        urlComps.scheme = wsScheme
        urlComps.host = baseUrl
        urlComps.port = port
        urlComps.path = "/progress"
        urlComps.queryItems = [
            URLQueryItem(name: "id", value: id.uuidString),
        ]
        
        if let url = urlComps.url {
            print(url.absoluteString)
            let task = URLSession.shared.webSocketTask(with: url)
            task.resume()
            receiveProgressUpdate(task: task)
        }
    }
    
    private func receiveProgressUpdate(task: URLSessionWebSocketTask) {
        var doContinue = true
        task.receive { result in
            switch result {
                case .failure(let error):
                    print("Encountered WebSocket error: \(error)")
                    self.error.send()
                    doContinue = false
                case .success(let message):
                    switch message {
                        case .string(let text):
                            doContinue = self.handleProgressUpdate(text: text)
                        case .data(_):
                            fallthrough
                        @unknown default:
                            print("Unsupported WebSocket Message Type")
                            self.error.send()
                            doContinue = false
                    }
            }
            if doContinue {
                self.receiveProgressUpdate(task: task)
            }
        }
    }
    
    private func handleProgressUpdate(text: String) -> Bool {
        if text == "Job failed" {
            error.send()
            return false
        } else if text == "Job complete" {
            progress.send(100)
            processingComplete.send()
            getResult()
            return false
        } else if let progressAmount = Int(text.removingLast()) { // e.g. "50%" -> "50" -> 50
            progress.send(progressAmount)
            return true
        }
        print("Unparsable Message \(text) received from WebSocket")
        return false
    }
    
    public func getResult() {
        var urlComps = URLComponents()
        urlComps.scheme = scheme
        urlComps.host = baseUrl
        urlComps.port = port
        urlComps.path = "/result"
        urlComps.queryItems = [
            URLQueryItem(name: "id", value: id.uuidString),
        ]
        
        if let url = urlComps.url {
            print(url.absoluteString)
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                guard let response = response as? HTTPURLResponse, let data = data, (200...299).contains(response.statusCode) else {
                    self.error.send()
                    print("Failed to retrieve result usdz file")
                    return
                }
                print("Successfully retrieved result usdz file")
                try? data.write(to: self.resultUrl)
                print("Successfully wrote usdz file to disk")
                self.complete.send()
            }
            
            task.resume()
        }
    }
}


