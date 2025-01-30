//
//  CameraViewModel.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/29/25.
//

import SwiftUI
import AVFoundation
import Photos

// MARK: - Camera View Model
class CameraViewModel: NSObject, ObservableObject {
    @Published var isCameraAuthorized = false
    @Published var isRecording = false
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var capturedImage: UIImage?
    @Published var recordedVideoURL: URL?
    @Published var isPreviewingMedia = false
    @Published var isFlashOn = false
    @Published var isFrontCamera = false
    @Published var recordingProgress: CGFloat = 0
    
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureMovieFileOutput?
    private var photoOutput: AVCapturePhotoOutput?
    private var recordingTimer: Timer?
    private let maxRecordingDuration: CGFloat = 10.0 // Maximum recording duration in seconds
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupCamera()
                    }
                }
            }
        default:
            break
        }
    }
    
    private func setupCamera() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let session = AVCaptureSession()
            
            // Configure the session for high quality video
            if session.canSetSessionPreset(.high) {
                session.sessionPreset = .high
            }
            
            // Set up video input
            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: .video,
                                                           position: .back),
                  let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                return
            }
            
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
            
            // Set up audio input
            if let audioDevice = AVCaptureDevice.default(for: .audio),
               let audioInput = try? AVCaptureDeviceInput(device: audioDevice),
               session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
            
            // Set up photo output
            let photo = AVCapturePhotoOutput()
            if session.canAddOutput(photo) {
                session.addOutput(photo)
                self?.photoOutput = photo
            }
            
            // Set up video output
            let video = AVCaptureMovieFileOutput()
            if session.canAddOutput(video) {
                session.addOutput(video)
                self?.videoOutput = video
            }
            
            // Create and setup preview layer
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            if #available(iOS 17.0, *) {
                previewLayer.connection?.videoRotationAngle = 90
            } else {
                previewLayer.connection?.videoOrientation = .portrait
            }
            
            // Start session
            session.startRunning()
            
            DispatchQueue.main.async {
                self?.captureSession = session
                self?.previewLayer = previewLayer
                self?.isCameraAuthorized = true
            }
        }
    }
    
    func toggleCamera() {
        guard let session = captureSession else { return }
        
        session.beginConfiguration()
        
        // Remove existing input
        for input in session.inputs {
            session.removeInput(input)
        }
        
        // Switch camera position
        let position: AVCaptureDevice.Position = isFrontCamera ? .back : .front
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                       for: .video,
                                                       position: position),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        // Re-add audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio),
           let audioInput = try? AVCaptureDeviceInput(device: audioDevice) {
            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            }
        }
        
        session.commitConfiguration()
        isFrontCamera.toggle()
    }
    
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        try? device.lockForConfiguration()
        if device.hasTorch {
            if device.torchMode == .off {
                try? device.setTorchModeOn(level: 1.0)
                isFlashOn = true
            } else {
                device.torchMode = .off
                isFlashOn = false
            }
        }
        device.unlockForConfiguration()
    }
    
    func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        
        let settings = AVCapturePhotoSettings()
        if isFlashOn {
            settings.flashMode = .on
        }
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func startRecording() {
        guard let videoOutput = videoOutput else { return }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).mov")
        videoOutput.startRecording(to: tempURL, recordingDelegate: self)
        isRecording = true
        
        // Start progress timer
        recordingProgress = 0
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.recordingProgress = min(self.recordingProgress + 0.1/self.maxRecordingDuration, 1.0)
            
            if self.recordingProgress >= 1.0 {
                self.stopRecording()
            }
        }
    }
    
    func stopRecording() {
        videoOutput?.stopRecording()
        recordingTimer?.invalidate()
        recordingTimer = nil
        isRecording = false
    }
}

// MARK: - Photo Capture Delegate
extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
            self.isPreviewingMedia = true
        }
    }
}

// MARK: - Video Recording Delegate
extension CameraViewModel: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if error == nil {
            DispatchQueue.main.async {
                self.recordedVideoURL = outputFileURL
                self.isPreviewingMedia = true
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
        view.layer.addSublayer(previewLayer)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        previewLayer.frame = uiView.bounds
        previewLayer.videoGravity = .resizeAspectFill
        // Ensure layout happens on main thread
        DispatchQueue.main.async {
            uiView.layer.layoutIfNeeded()
        }
    }
}

// MARK: - Progress Bar View
struct RecordingProgressBar: View {
    let progress: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 4)
                
                Rectangle()
                    .fill(Color.red)
                    .frame(width: geometry.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Media Preview View
struct MediaPreviewView: View {
    let image: UIImage?
    let videoURL: URL?
    @Binding var isShowing: Bool
    var onSend: () -> Void
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if let url = videoURL {
                VideoPlayer(url: url)
            }
            
            VStack {
                HStack {
                    Button(action: { isShowing = false }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .font(.title)
                            .padding()
                    }
                    Spacer()
                }
                Spacer()
                Button(action: onSend) {
                    Text("Send")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(25)
                }
                .padding(.bottom, 40)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .background(Color.black)
    }
}

// MARK: - Video Player View
struct VideoPlayer: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        let player = AVPlayer(url: url)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(playerLayer)
        player.play()
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerLayer = uiView.layer.sublayers?.first as? AVPlayerLayer {
            playerLayer.frame = uiView.bounds
        }
    }
}
