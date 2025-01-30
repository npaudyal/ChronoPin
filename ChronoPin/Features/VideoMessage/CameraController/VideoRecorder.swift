////
////  VideoRecorder.swift
////  ChronoPin
////
////  Created by Nischal Paudyal on 1/28/25.
////
//import SwiftUI
//import AVFoundation
//import FirebaseStorage
//import FirebaseFirestore
//import FirebaseAuth
//import MapKit
//
//class VideoRecorder: NSObject, ObservableObject {
//    @Published var recordedVideoURL: URL?
//    @Published var previewLayer: AVCaptureVideoPreviewLayer?
//    @Published var isConfigured = false
//    @Published var setupError: String?
//    
//    private var captureSession: AVCaptureSession?
//    private var videoOutput: AVCaptureMovieFileOutput?
//    
//    override init() {
//        super.init()
//        print("VideoRecorder initialized")
//    }
//    
//    private func setupCaptureSession() {
//        DispatchQueue.main.async { [weak self] in
//            print("🎥 Starting capture session setup")
//            
//            let session = AVCaptureSession()
//            session.beginConfiguration()
//            print("🎥 Session configuration begun")
//            
//            // Set the session preset
//            if session.canSetSessionPreset(.high) {
//                session.sessionPreset = .high
//            }
//            
//            // Video input setup
//            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
//                print("❌ Could not find video device")
//                self?.setupError = "Could not find video device"
//                return
//            }
//            print("✅ Found video device")
//            
//            do {
//                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
//                if session.canAddInput(videoInput) {
//                    session.addInput(videoInput)
//                    print("✅ Added video input")
//                } else {
//                    print("❌ Could not add video input to session")
//                }
//            } catch {
//                print("❌ Error setting up video input: \(error)")
//                self?.setupError = "Could not setup video input: \(error.localizedDescription)"
//                return
//            }
//            
//            // Video output setup
//            let videoOutput = AVCaptureMovieFileOutput()
//            if session.canAddOutput(videoOutput) {
//                session.addOutput(videoOutput)
//                print("✅ Added video output")
//            } else {
//                print("❌ Could not add video output")
//            }
//            
//            // Create and setup preview layer before committing configuration
//            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//            previewLayer.videoGravity = .resizeAspectFill
//            previewLayer.connection?.videoRotationAngle = 90
//            
//            // Commit configuration
//            session.commitConfiguration()
//            print("✅ Session configuration committed")
//            
//            // Store references
//            self?.videoOutput = videoOutput
//            self?.captureSession = session
//            self?.previewLayer = previewLayer
//            print("✅ Preview layer created")
//            
//            // Mark as configured
//            self?.isConfigured = true
//            
//            // Start running session after configuration is committed
//            DispatchQueue.global(qos: .userInitiated).async {
//                session.startRunning()
//                print("✅ Session started running")
//            }
//        }
//    }
//    
//    func checkPermissionsAndSetup() {
//        print("Checking camera permissions")
//        
//        // Check if already configured
//        guard !isConfigured else {
//            print("Already configured")
//            return
//        }
//        
//        // Check and request permissions
//        AVCaptureDevice.requestAccess(for: .video) { [weak self] videoGranted in
//            guard videoGranted else {
//                DispatchQueue.main.async {
//                    self?.setupError = "Camera access denied"
//                }
//                return
//            }
//            
//            AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
//                guard audioGranted else {
//                    DispatchQueue.main.async {
//                        self?.setupError = "Microphone access denied"
//                    }
//                    return
//                }
//                
//                DispatchQueue.main.async {
//                    self?.setupCaptureSession()
//                }
//            }
//        }
//    }
//    
//    func startRecording() {
//        guard let videoOutput = videoOutput else { return }
//        
//        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
//        videoOutput.startRecording(to: tempURL, recordingDelegate: self)
//    }
//    
//    func stopRecording() {
//        videoOutput?.stopRecording()
//    }
//}
//
//// MARK: - AVCaptureFileOutputRecordingDelegate
//extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        if error == nil {
//            DispatchQueue.main.async {
//                self.recordedVideoURL = outputFileURL
//            }
//        }
//    }
//}
