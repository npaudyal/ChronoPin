//
//  VideoRecordingView.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/27/25.
//

import SwiftUI
import AVFoundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
import MapKit

struct VideoRecordingView: View {
    let coordinate: CLLocationCoordinate2D
    @Environment(\.dismiss) var dismiss
    @StateObject private var videoRecorder = VideoRecorder()
    @State private var isRecording = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isUploading = false
    
    var body: some View {
        ZStack {
            if let previewLayer = videoRecorder.previewLayer {
                CameraPreviewView(previewLayer: previewLayer)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
            
            // Controls overlay
            VStack {
                // Close button
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                }
                .padding(.top, 44) // Add padding for safe area
                
                Spacer()
                
                // Record button
                if videoRecorder.isConfigured {
                    Button(action: {
                        if isRecording {
                            videoRecorder.stopRecording()
                            isRecording = false
                        } else {
                            videoRecorder.startRecording()
                            isRecording = true
                        }
                    }) {
                        Circle()
                            .fill(isRecording ? .red : .white)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                                    .frame(width: 70, height: 70)
                            )
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            videoRecorder.checkPermissionsAndSetup()
        }
    }

    
    private func uploadVideoAndSavePin() {
        guard let videoURL = videoRecorder.recordedVideoURL else { return }
        isUploading = true
        
        // Upload to Firebase Storage
        let storageRef = Storage.storage().reference()
        let videoName = "\(UUID().uuidString).mov"
        let videoRef = storageRef.child("videos/\(videoName)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        videoRef.putFile(from: videoURL, metadata: metadata) { metadata, error in
            if let error = error {
                errorMessage = "Upload failed: \(error.localizedDescription)"
                showErrorAlert = true
                isUploading = false
                return
            }
            
            // Get download URL
            videoRef.downloadURL { url, error in
                if let error = error {
                    errorMessage = "Failed to get download URL: \(error.localizedDescription)"
                    showErrorAlert = true
                    isUploading = false
                    return
                }
                
                guard let downloadURL = url else { return }
                saveVideoPin(videoURL: downloadURL.absoluteString)
            }
        }
    }
    
    private func saveVideoPin(videoURL: String) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to save a pin."
            showErrorAlert = true
            isUploading = false
            return
        }
        
        let geoPoint = GeoPoint(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        let pinData: [String: Any] = [
            "userId": user.uid,
            "type": "video",
            "content": videoURL,
            "location": geoPoint,
            "createdAt": Timestamp(date: Date()),
            "unlockConditions": ["type": "time", "unlockTime": Timestamp(date: Date())],
            "isPublic": false
        ]
        
        Firestore.firestore().collection("pins").addDocument(data: pinData) { error in
            isUploading = false
            if let error = error {
                errorMessage = "Failed to save: \(error.localizedDescription)"
                showErrorAlert = true
            } else {
                dismiss()
            }
        }
    }
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("📱 Updating camera preview UIView bounds: \(uiView.bounds)")
        DispatchQueue.main.async {
            previewLayer.frame = uiView.bounds
        }
    }
}

// MARK: - Video Recorder
class VideoRecorder: NSObject, ObservableObject {
    @Published var recordedVideoURL: URL?
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var isConfigured = false
    @Published var setupError: String?
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    
    override init() {
        super.init()
        print("VideoRecorder initialized")
    }
    
    private func setupCaptureSession() {
        DispatchQueue.main.async { [weak self] in
            print("🎥 Starting capture session setup")
            
            let session = AVCaptureSession()
            session.beginConfiguration()
            print("🎥 Session configuration begun")
            
            // Set the session preset
            if session.canSetSessionPreset(.high) {
                session.sessionPreset = .high
            }
            
            // Video input setup
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                print("❌ Could not find video device")
                self?.setupError = "Could not find video device"
                return
            }
            print("✅ Found video device")
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoDevice)
                if session.canAddInput(videoInput) {
                    session.addInput(videoInput)
                    print("✅ Added video input")
                } else {
                    print("❌ Could not add video input to session")
                }
            } catch {
                print("❌ Error setting up video input: \(error)")
                self?.setupError = "Could not setup video input: \(error.localizedDescription)"
                return
            }
            
            // Video output setup
            let videoOutput = AVCaptureMovieFileOutput()
            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                print("✅ Added video output")
            } else {
                print("❌ Could not add video output")
            }
            
            // Create and setup preview layer before committing configuration
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.connection?.videoOrientation = .portrait
            
            // Commit configuration
            session.commitConfiguration()
            print("✅ Session configuration committed")
            
            // Store references
            self?.videoOutput = videoOutput
            self?.captureSession = session
            self?.previewLayer = previewLayer
            print("✅ Preview layer created")
            
            // Mark as configured
            self?.isConfigured = true
            
            // Start running session after configuration is committed
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
                print("✅ Session started running")
            }
        }
    }
    
    func checkPermissionsAndSetup() {
        print("Checking camera permissions")
        
        // Check if already configured
        guard !isConfigured else {
            print("Already configured")
            return
        }
        
        // Check and request permissions
        AVCaptureDevice.requestAccess(for: .video) { [weak self] videoGranted in
            guard videoGranted else {
                DispatchQueue.main.async {
                    self?.setupError = "Camera access denied"
                }
                return
            }
            
            AVCaptureDevice.requestAccess(for: .audio) { audioGranted in
                guard audioGranted else {
                    DispatchQueue.main.async {
                        self?.setupError = "Microphone access denied"
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self?.setupCaptureSession()
                }
            }
        }
    }
    
    func startRecording() {
        guard let videoOutput = videoOutput else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        videoOutput.startRecording(to: tempURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            DispatchQueue.main.async {
                self.recordedVideoURL = outputFileURL
            }
        }
    }
}

