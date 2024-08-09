import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // Camera session variables
    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureMovieFileOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?

    // UI Elements
    let isoLabel = UILabel()
    let isoSlider = UISlider()
    let shutterSpeedLabel = UILabel()
    let shutterSpeedSlider = UISlider()
    let stabilizationLabel = UILabel()
    let stabilizationSwitch = UISwitch()
    let exportButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupUI()
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        guard let session = captureSession else { return }
        
        session.beginConfiguration()
        
        // Setup inputs
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("Device not connected")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            print("Error setting up video input: \(error)")
            return
        }
        
        // Setup outputs
        videoOutput = AVCaptureMovieFileOutput()
        if let output = videoOutput, session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        if let layer = previewLayer {
            layer.frame = view.bounds
            view.layer.insertSublayer(layer, at: 0)
        }

        session.startRunning()
    }
    
    func setupUI() {
        view.backgroundColor = UIColor.white
        
        isoLabel.text = "ISO"
        isoLabel.textColor = UIColor.black
        isoLabel.frame = CGRect(x: 20, y: view.frame.height - 240, width: 100, height: 30)
        view.addSubview(isoLabel)
        
        isoSlider.minimumValue = 100
        isoSlider.maximumValue = 3200
        isoSlider.value = 400
        isoSlider.frame = CGRect(x: 120, y: view.frame.height - 240, width: view.frame.width - 140, height: 30)
        isoSlider.addTarget(self, action: #selector(isoChanged(_:)), for: .valueChanged)
        view.addSubview(isoSlider)
        
        shutterSpeedLabel.text = "Shutter Speed"
        shutterSpeedLabel.textColor = UIColor.black
        shutterSpeedLabel.frame = CGRect(x: 20, y: view.frame.height - 180, width: 200, height: 30)
        view.addSubview(shutterSpeedLabel)
        
        shutterSpeedSlider.minimumValue = 1 / 8000
        shutterSpeedSlider.maximumValue = 1 / 30
        shutterSpeedSlider.value = 1 / 60
        shutterSpeedSlider.frame = CGRect(x: 220, y: view.frame.height - 180, width: view.frame.width - 240, height: 30)
        shutterSpeedSlider.addTarget(self, action: #selector(shutterSpeedChanged(_:)), for: .valueChanged)
        view.addSubview(shutterSpeedSlider)
        
        stabilizationLabel.text = "Stabilization"
        stabilizationLabel.textColor = UIColor.black
        stabilizationLabel.frame = CGRect(x: 20, y: view.frame.height - 120, width: 100, height: 30)
        view.addSubview(stabilizationLabel)
        
        stabilizationSwitch.isOn = false
        stabilizationSwitch.frame = CGRect(x: 120, y: view.frame.height - 120, width: 50, height: 30)
        stabilizationSwitch.addTarget(self, action: #selector(stabilizationChanged(_:)), for: .valueChanged)
        view.addSubview(stabilizationSwitch)
        
        exportButton.setTitle("Export to Slog", for: .normal)
        exportButton.setTitleColor(UIColor.white, for: .normal)
        exportButton.backgroundColor = UIColor.blue
        exportButton.frame = CGRect(x: 20, y: view.frame.height - 60, width: view.frame.width - 40, height: 50)
        exportButton.addTarget(self, action: #selector(exportToSlog), for: .touchUpInside)
        view.addSubview(exportButton)
    }
    
    @objc func isoChanged(_ sender: UISlider) {
        if let device = AVCaptureDevice.default(for: .video) {
            self.changeDeviceSettings(device: device, isoValue: sender.value)
        }
    }
    
    @objc func shutterSpeedChanged(_ sender: UISlider) {
        if let device = AVCaptureDevice.default(for: .video) {
            self.changeDeviceSettings(device: device, shutterSpeedValue: sender.value)
        }
    }
    
    @objc func stabilizationChanged(_ sender: UISwitch) {
        if let device = AVCaptureDevice.default(for: .video) {
            self.toggleStabilization(device: device, isEnabled: sender.isOn)
        }
    }
    
    func changeDeviceSettings(device: AVCaptureDevice, isoValue: Float? = nil, shutterSpeedValue: Float? = nil) {
        do {
            try device.lockForConfiguration()
            if let iso = isoValue {
                device.setExposureModeCustom(duration: AVCaptureDevice.currentExposureDuration, iso: iso, completionHandler: nil)
            }
            if let shutterSpeed = shutterSpeedValue {
                device.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: Int32(1 / shutterSpeed)), iso: device.iso, completionHandler: nil)
            }
            device.unlockForConfiguration()
        } catch {
            print("Error changing device settings: \(error)")
        }
    }
    
    func toggleStabilization(device: AVCaptureDevice, isEnabled: Bool) {
        do {
            try device.lockForConfiguration()
            if device.activeVideoMaxFrameDuration != device.activeVideoMinFrameDuration {
                device.activeVideoMaxFrameDuration = device.activeVideoMinFrameDuration
                device.isSmoothAutoFocusEnabled = isEnabled
            }
            device.unlockForConfiguration()
        } catch {
            print("Error toggling stabilization: \(error)")
        }
    }
    
    @objc func exportToSlog() {
        // Placeholder logic for export to Slog
        print("Exporting to Slog...")
    }
}