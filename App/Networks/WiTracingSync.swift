//
//  WiTracingSync.swift
//  App
//
//  Created by x on 5/11/2022.
//

import Foundation
import Network

// Title: WiTracingSync
// WiTracing synchronizer connect with the simulator through UDP protocol
// It synchronize the test data including wireless signal measurement
// and the ground true position
// Style: Singleton

class WiTracingSync : ObservableObject {
    /// ----------------------------------------------
    /// singleton style
    private static var _shared: WiTracingSync = {
        return WiTracingSync(port: 8888)
    }()
    class func shared() -> WiTracingSync {
        return self._shared
    }
    /// ----------------------------------------------
    
    /// properties
    private let queue = DispatchQueue.global(qos: .userInitiated)
    private let port: NWEndpoint.Port
    private var listener: NWListener?
    private var connection: NWConnection?
    private var recvData: [String: Any]?
    private var bReady: Bool = false
    private var bListening: Bool = true
    
    /// initializer
    init (port: NWEndpoint.Port) {
        self.port = port
        self.listener = try? NWListener(using: .udp, on: self.port)
        self.listener?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("[INF] UDP Ready")
                self.bReady = true
            case .failed:
                print("[INF] UDP Failed")
                self.bReady = false
            case .cancelled:
                print("[INF] UDP Cancelled")
                self.bListening = false
                self.bReady = false
            default:
                print("[INF] UDP Unknown")
            }
            
        }
        self.listener?.newConnectionHandler = { connection in
            print("[INF] Listener receiving new message")
            self.createConnection(connection: connection)
        }
        self.listener?.start(queue: self.queue)
    }
    
    ///
    func createConnection(connection: NWConnection) {
        self.connection = connection
        self.connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                //print("[INF] Listener ready to receive message - \(connection.endpoint)")
                /// received message
                self.recv()
                self.send()
            case .cancelled, .failed:
                //print("[INF] Listener failed to receive message - \(connection.endpoint)")
                /// cancel the listener
                self.listener?.cancel()
                self.bListening = false
            default:
                //print("[INF] Listener waiting to receive message - \(connection.endpoint)")
                break
            }
        }
        self.connection?.start(queue: .global())
    }
    
    func recv() {
        self.connection?.receiveMessage(completion: { data, context, isComplete, error in
            if let error = error {
                print("[ERR] NWError received in \(#function) - \(error)")
                return
            }
            guard isComplete, let data = data else {
                print("[ERR] Received nil Data with context -\(String(describing: data))")
                return
            }
            if let data = try? JSONDecoder().decode(WiTracingData.self, from: data) {/// convert from milliseconds to seconds
                NotificationCenter.default.post(name: Constant.NotificationNameWiTracingDidRecvData, object: nil, userInfo: data.toAppUnit().toDict())
            } else {
                print("[ERR] unable to decode")
            }
            if self.bListening {
                self.recv()
            }
        })
    }
    
    func send() {
        self.connection?.send(content: "Test message".data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ error in
            if let error = error {
                print("[ERR] \(#function) - \(error)")
            }
        })))
    }
    
    func cancel() {
        self.bListening = false
        self.connection?.cancel()
    }
}
