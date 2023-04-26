//
//  Constant.swift
//  App
//
//  Created by x on 5/11/2022.
//

import Foundation

class Constant {
    /// Common
    static let Prediction = "Prediction"
    static let PredictionTrajectory = "Prediction Trajectory"
    static let PredictionMovingAverage = "Prediction Moving Average"
    static let PredictionMovingAverageTrajectory = "Prediction MA Trajectory"
    static let GroundTruth = "Ground Truth"
    static let GroundTruthTrajectory = "GT Trajectory"
    static let Settings = "Settings"
    static let RecurrentNeuralNetwork = "Recurrent neural network"
    static let RNN = "RNN"
    static let Trilateration = "Trilateration"
    static let DeepLearning = "Deep Learning"
    static let Transmitters = "Transmitters"
    static let Receivers = "Transmitters"
    static let TX = "TX"
    /// Notification
    static let NotificationNameWiTracingDidRecvData = Notification.Name("WiTracing.DidRecvData")
    /// File name
    static let ConfigurationFilename = "configuration"
    static let MeanStdFilename = "meanstd"
    /// Icon
    static let TXIcon = "dot.radiowaves.left.and.right"
    static let PredictionIcon = "target"
    static let SettingsIcon = "gearshape.fill"
    static let DeepLearningIcon = "brain"
    static let ARIcon = "aqi.medium"
    /// Parameters
    static let MinRSSI: Int = -100
}


