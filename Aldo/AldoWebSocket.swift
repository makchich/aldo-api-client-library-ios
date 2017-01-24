//
//  AldoWebSocket.swift
//  Pods
//
//  Created by Team Aldo on 24/01/2017.
//
//

import Foundation
import Starscream

/// Class representing a WebSocket connection to the Aldo Framework.
public class AldoWebSocket: WebSocketDelegate {

    private var request: String
    private var socket: WebSocket
    private var callback: Callback

    /**
     Initializer.
     
     - Parameters:
        - path: The path to subscribe to.
        - url: An instance of *URL* representing the absolute path to subscribe to.
        - callback: A realization of the Callback protocol to be called
                 when a response is returned from the Aldo Framework.
     */
    public init(path: String, url: URL, callback: Callback) {
        self.request = path
        self.socket = WebSocket(url: url)
        self.callback = callback

        self.socket.headers["Authorization"] = Aldo.getAuthorizationHeaderValue()
        self.socket.delegate = self
    }

    public func websocketDidConnect(socket: WebSocket) {
        callback.onResponse(request: self.request, responseCode: 100, response: [:])
    }

    public func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        var json: [String: Any] = [:]
        json["info"] = "Disconnected from the Aldo Framework."
        if error != nil {
            json["info"] = "Lost connection with the Aldo Framework."
        }
        let response = json as NSDictionary
        callback.onResponse(request: self.request, responseCode: 503, response: response)
    }

    public func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        if !text.isEmpty {
            var response = [:] as NSDictionary
            if let json = convertToDictionary(text: text) {
                response = json
            }
            callback.onResponse(request: self.request, responseCode: 200, response: response)
        }
    }

    public func websocketDidReceiveData(socket: WebSocket, data: Data) {
        if !data.isEmpty {
            var response = [:] as NSDictionary
            if let json = convertToDictionary(data: data) {
                response = json
            }
            callback.onResponse(request: self.request, responseCode: 200, response: response)
        }
    }

    /// Opens the connection to the Aldo Framework.
    public func connect() {
        if !socket.isConnected {
            socket.connect()
        }
    }

    /// Closes the connection to the Aldo Framework.
    public func disconnect() {
        if socket.isConnected {
            socket.disconnect()
        }
    }

    /**
     Helper method to convert a JSON string to a NSDictionary.
     Found on [StackOverflow](http://stackoverflow.com/a/30480777)
     
     - Parameter text: The JSON string.
     
     - Returns: An instance of *NSDictionary*
                or *nil* if the passed string is not a (valid) JSON.
     */
    private func convertToDictionary(text: String) -> NSDictionary? {
        if let data = text.data(using: .utf8) {
            return convertToDictionary(data: data)
        }
        return nil
    }

    /**
     Helper method to convert a JSON string to a NSDictionary.
     Found on [StackOverflow](http://stackoverflow.com/a/30480777)
     
     - Parameter data: A *Data* object representing the JSON string.
     
     - Returns: An instance of *NSDictionary*
                or *nil* if the passed data is not a (valid) JSON.
     */
    private func convertToDictionary(data: Data) -> NSDictionary? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
                as? NSDictionary
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
}
