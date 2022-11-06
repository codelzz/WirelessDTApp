//
//  UDPAgent.swift
//  App
//
//  Created by x on 4/11/2022.
//

import Foundation
import Network

protocol UDPAgentDelegate {
    func didRecvData(_ data: Data)
}

class UDPAgent : ObservableObject {
    var delegate: UDPAgentDelegate?
    var queue = DispatchQueue.global(qos: .userInitiated)
    let listener: NWListener?
    var connection: NWConnection?
    let port: NWEndpoint.Port
    /// New Data
    @Published private(set) public var recvData: [String: Any]?
    /// Flag for active listening connection
    @Published private(set) public var bReady: Bool = false
    /// Flag for listening state
    @Published public var bListening: Bool = true
    
    init (port: NWEndpoint.Port, queue: DispatchQueue?) {
        if let queue = queue {
            self.queue = queue
        }
        
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
    
    func createConnection(connection: NWConnection) {
        self.connection = connection
        self.connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("[INF] Listener ready to receive message - \(connection.endpoint)")
                /// received message
                self.recv()
                self.send()
            case .cancelled, .failed:
                print("[INF] Listener failed to receive message - \(connection.endpoint)")
                /// cancel the listener
                self.listener?.cancel()
                self.bListening = false
            default:
                print("[INF] Listener waiting to receive message - \(connection.endpoint)")
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
            self.delegate?.didRecvData(data)
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
    
    static func decode(data: Data) -> [String : Any]? {
        var json : [String : Any]?
        do{
            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        }
        catch
        {
            print("[ERR] \(error)")
        }
        return json
    }
}


