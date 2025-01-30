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
    //@StateObject private var videoRecorder = VideoRecorder()
    @StateObject private var viewModel = CameraViewModel()
    @State private var isRecording = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var isUploading = false
    
    //@StateObject private var viewModel = CameraViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Camera Preview
                if let previewLayer = viewModel.previewLayer {
                    CameraPreviewView(previewLayer: previewLayer)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    Color.black
                }
                
                // Recording Progress Bar
                if viewModel.isRecording {
                    RecordingProgressBar(progress: viewModel.recordingProgress)
                        .padding(.top, 5)
                        .frame(maxHeight: .infinity, alignment: .top)
                }
                
                // Controls
                VStack {
                    // Top controls
                    HStack {
                        Button(action: { viewModel.toggleFlash() }) {
                            Image(systemName: viewModel.isFlashOn ? "bolt.fill" : "bolt.slash")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .padding()
                        }
                        Spacer()
                        Button(action: { viewModel.toggleCamera() }) {
                            Image(systemName: "camera.rotate")
                                .foregroundColor(.white)
                                .font(.system(size: 20))
                                .padding()
                        }
                    }
                    .padding(.top, 44)
                    
                    Spacer()
                    
                    // Bottom controls
                    HStack {
                        Spacer()
                        
                        // Camera button
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.capturePhoto()
                            }
                        }) {
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                                .frame(width: 80, height: 80)
                        }
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 0.5)
                                .onEnded { _ in
                                    viewModel.startRecording()
                                }
                        )
                        
                        Spacer()
                    }
                    .padding(.bottom, 40)
                }
                
                // Media Preview
                if viewModel.isPreviewingMedia {
                    MediaPreviewView(
                        image: viewModel.capturedImage,
                        videoURL: viewModel.recordedVideoURL,
                        isShowing: $viewModel.isPreviewingMedia
                    ) {
                        // Handle sending media
                        print("Send media")
                    }
                }
            }
            
            
            //    public func uploadVideoAndSavePin() {
            //        guard let videoURL = videoRecorder.recordedVideoURL else { return }
            //        isUploading = true
            //
            //        // Upload to Firebase Storage
            //        let storageRef = Storage.storage().reference()
            //        let videoName = "\(UUID().uuidString).mov"
            //        let videoRef = storageRef.child("videos/\(videoName)")
            //
            //        let metadata = StorageMetadata()
            //        metadata.contentType = "video/quicktime"
            //
            //        videoRef.putFile(from: videoURL, metadata: metadata) { metadata, error in
            //            if let error = error {
            //                errorMessage = "Upload failed: \(error.localizedDescription)"
            //                showErrorAlert = true
            //                isUploading = false
            //                return
            //            }
            //
            //            // Get download URL
            //            videoRef.downloadURL { url, error in
            //                if let error = error {
            //                    errorMessage = "Failed to get download URL: \(error.localizedDescription)"
            //                    showErrorAlert = true
            //                    isUploading = false
            //                    return
            //                }
            //
            //                guard let downloadURL = url else { return }
            //                saveVideoPin(videoURL: downloadURL.absoluteString)
            //            }
            //        }
            //    }
            //
            //    public func saveVideoPin(videoURL: String) {
            //        guard let user = Auth.auth().currentUser else {
            //            errorMessage = "You must be logged in to save a pin."
            //            showErrorAlert = true
            //            isUploading = false
            //            return
            //        }
            //
            //        let geoPoint = GeoPoint(
            //            latitude: coordinate.latitude,
            //            longitude: coordinate.longitude
            //        )
            //
            //        let pinData: [String: Any] = [
            //            "userId": user.uid,
            //            "type": "video",
            //            "content": videoURL,
            //            "location": geoPoint,
            //            "createdAt": Timestamp(date: Date()),
            //            "unlockConditions": ["type": "time", "unlockTime": Timestamp(date: Date())],
            //            "isPublic": false
            //        ]
            //
            //        Firestore.firestore().collection("pins").addDocument(data: pinData) { error in
            //            isUploading = false
            //            if let error = error {
            //                errorMessage = "Failed to save: \(error.localizedDescription)"
            //                showErrorAlert = true
            //            } else {
            //                dismiss()
            //            }
            //        }
            //    }
        }
    }
}
