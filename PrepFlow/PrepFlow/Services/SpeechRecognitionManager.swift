import Foundation
import Combine
import Speech
import AVFoundation

// MARK: - Speech Recognition Manager
class SpeechRecognitionManager: ObservableObject {
    @Published var transcribedText: String = ""
    @Published var isRecording: Bool = false
    @Published var isAuthorized: Bool = false
    @Published var errorMessage: String?

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()

    init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    func checkAuthorization() {
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            isAuthorized = true
        case .notDetermined:
            isAuthorized = false
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }

    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    self?.isAuthorized = true
                    self?.errorMessage = nil
                case .denied:
                    self?.isAuthorized = false
                    self?.errorMessage = "Speech recognition access denied. Please enable in Settings."
                case .restricted:
                    self?.isAuthorized = false
                    self?.errorMessage = "Speech recognition is restricted on this device."
                case .notDetermined:
                    self?.isAuthorized = false
                @unknown default:
                    self?.isAuthorized = false
                }
            }
        }
    }

    // MARK: - Recording

    func startRecording() {
        // Check if already recording
        guard !isRecording else { return }

        // Check authorization
        guard isAuthorized else {
            requestAuthorization()
            return
        }

        // Check if speech recognizer is available
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorMessage = "Speech recognition is not available. Please check your internet connection."
            return
        }

        // Reset any previous task
        resetRecognition()

        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            errorMessage = "Failed to configure audio session: \(error.localizedDescription)"
            return
        }

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        guard let recognitionRequest = recognitionRequest else {
            errorMessage = "Unable to create speech recognition request."
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        // For iOS 16+, enable on-device recognition if available
        if #available(iOS 16, *) {
            recognitionRequest.requiresOnDeviceRecognition = false
        }

        // Create recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            var isFinal = false

            if let result = result {
                DispatchQueue.main.async {
                    self.transcribedText = result.bestTranscription.formattedString
                }
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                DispatchQueue.main.async {
                    if self.isRecording {
                        self.stopRecording()
                    }
                }
            }
        }

        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        // Start audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()

            DispatchQueue.main.async {
                self.isRecording = true
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to start audio engine: \(error.localizedDescription)"
            }
        }
    }

    func stopRecording() {
        guard isRecording else { return }

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        recognitionRequest = nil
        recognitionTask = nil

        DispatchQueue.main.async {
            self.isRecording = false
        }

        // Deactivate audio session
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            // Ignore errors when deactivating
        }
    }

    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    func clearTranscription() {
        transcribedText = ""
    }

    private func resetRecognition() {
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil

        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
    }
}
