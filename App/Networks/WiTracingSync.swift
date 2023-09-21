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
        return WiTracingSync(port: 7777)
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
    /// socket
//    private var nextID: Int = 0
//    private var connectionHandlers: [Int: ConnectionHandler] = [:]
    private var incompletedData: String = ""
    
    /// initializer
    init (port: NWEndpoint.Port) {
        self.port = port
        self.listener = try? NWListener(using: .udp, on: self.port)
        self.listener?.stateUpdateHandler = self.listenerStateUpdateHandler(to:)
        self.listener?.newConnectionHandler = self.listenerNewConnectionHander(connection:)
        self.listener?.start(queue: self.queue)
    }
    
    /// state update handler
    func listenerStateUpdateHandler(to newState: NWListener.State) {
        switch newState {
        case .setup:
            print("[INF] Listener Setup")
        case .waiting:
            print("[INF] Listener Waiting")
        case .ready:
            print("[INF] Listener Ready")
            self.bReady = true
        case .failed:
            print("[INF] Listener Failed")
            self.bReady = false
        case .cancelled:
            print("[INF] Listener Cancelled")
            self.bReady = false
        default:
            print("[INF] Listener Unknown")
        }
    }
    
    func listenerNewConnectionHander(connection: NWConnection) {
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
                break
            }
        }
        self.connection?.start(queue: .global())
    }
    
    func recv() {
        self.connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536, completion: { data, context, isComplete, error in
            if let error = error {
                print("[ERR] NWError received in \(#function) - \(error)")
                return
            }
            if let data = data, !data.isEmpty {
                if let strData = String(bytes: data, encoding: .utf8) {
                    let list = strData.split(separator: /}/)
                    for (index, str) in list.enumerated() {
                        if let fragmentData = (str + "}").data(using: .utf8) {
                            if let data = try? JSONDecoder().decode(WiTracingData.self, from: fragmentData) {/// convert from milliseconds to seconds
                                NotificationCenter.default.post(name: Constant.NotificationNameWiTracingDidRecvData, object: nil, userInfo: data.toAppUnit().toDict())
                            } else {
                                ///[Unhandle Exception]: In some case the recv stream is inComplete
                                /// the parse json operation will fail due to incomplete bytes, this need to be fixed in the future
                                if (index == 0) {
                                    if let fixedData = (self.incompletedData + str + "}").data(using: .utf8) {
                                        if let data = try? JSONDecoder().decode(WiTracingData.self, from: fixedData) {/// convert from milliseconds to seconds
                                            NotificationCenter.default.post(name: Constant.NotificationNameWiTracingDidRecvData, object: nil, userInfo: data.toAppUnit().toDict())
                                            self.incompletedData = ""
                                        } else {
//                                            print("[ERR] unable to parse ", index, "of", list.count, "with\n", String(bytes: fixedData, encoding: .utf8)!)
                                            print("[ERR] unable to parse ", index, "of", list.count, "with", fixedData)
                                        }
                                    }
                                } else {
                                    self.incompletedData = String(str)
                                }
                            }
                        } else {
                            print("[ERR] unable to parse", str, "}")
                        }
                    }
                }
            }
            if self.bListening {
                self.recv()
            }
            if !isComplete {
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
        self.connection?.cancel()
    }
    
    static public func parseWiTracingData(userInfo: [String: Any]) -> WiTracingData? {
        return nil
    }
}


//class WiTracingSync : ObservableObject {
//    /// ----------------------------------------------
//    /// singleton style
//    private static var _shared: WiTracingSync = {
//        return WiTracingSync(port: 7777)
//    }()
//    class func shared() -> WiTracingSync {
//        return self._shared
//    }
//    /// ----------------------------------------------
//
//    /// properties
//    private let queue = DispatchQueue.global(qos: .userInitiated)
//    private let port: NWEndpoint.Port
//    private var listener: NWListener?
//    private var connection: NWConnection?
//    private var recvData: [String: Any]?
//    private var bReady: Bool = false
//    private var bListening: Bool = true
//
//    /// initializer
//    init (port: NWEndpoint.Port) {
//        self.port = port
//        self.listener = try? NWListener(using: .tcp, on: self.port)
//        self.listener?.stateUpdateHandler = { newState in
//            switch newState {
//            case .ready:
//                print("[INF] Listener Ready")
//                self.bReady = true
//            case .failed:
//                print("[INF] Listener Failed")
//                self.bReady = false
//            case .cancelled:
//                print("[INF] Listener Cancelled")
//                self.bListening = false
//                self.bReady = false
//            default:
//                print("[INF] Listener Unknown")
//            }
//
//        }
//        self.listener?.newConnectionHandler = { connection in
//            print("[INF] Listener receiving new message")
//            self.createConnection(connection: connection)
//        }
//        self.listener?.start(queue: self.queue)
//    }
//
//    ///
//    func createConnection(connection: NWConnection) {
//        self.connection = connection
//        self.connection?.stateUpdateHandler = { newState in
//            switch newState {
//            case .ready:
//                //print("[INF] Listener ready to receive message - \(connection.endpoint)")
//                /// received message
//                self.recv()
//                self.send()
//            case .cancelled, .failed:
//                //print("[INF] Listener failed to receive message - \(connection.endpoint)")
//                /// cancel the listener
//                self.listener?.cancel()
//                self.bListening = false
//            default:
//                //print("[INF] Listener waiting to receive message - \(connection.endpoint)")
//                break
//            }
//        }
//        self.connection?.start(queue: .global())
//    }
//
//    func recv() {
//        self.connection?.receiveMessage(completion: { data, context, isComplete, error in
//            if let error = error {
//                print("[ERR] NWError received in \(#function) - \(error)")
//                return
//            }
//            guard isComplete, let data = data else {
//                print("[ERR] Received nil Data with context -\(String(describing: data))")
//                return
//            }
//            if let data = try? JSONDecoder().decode(WiTracingData.self, from: data) {/// convert from milliseconds to seconds
//                NotificationCenter.default.post(name: Constant.NotificationNameWiTracingDidRecvData, object: nil, userInfo: data.toAppUnit().toDict())
//            } else {
//                print("[ERR] unable to decode")
//            }
//            if self.bListening {
//                self.recv()
//            }
//        })
//    }
//
//    func send() {
//        self.connection?.send(content: "Test message".data(using: String.Encoding.utf8), completion: NWConnection.SendCompletion.contentProcessed(({ error in
//            if let error = error {
//                print("[ERR] \(#function) - \(error)")
//            }
//        })))
//    }
//
//    func cancel() {
//        self.bListening = false
//        self.connection?.cancel()
//    }
//
//    static public func parseWiTracingData(userInfo: [String: Any]) -> WiTracingData? {
//
//
//        return nil
//    }
//}
