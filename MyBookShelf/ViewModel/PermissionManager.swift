import Foundation
import AVFoundation
import UIKit
import CoreLocation
import LocalAuthentication

class PermissionManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isCameraAuthorized: Bool = false
    @Published var isLocationAuthorized: Bool = false
    @Published var isBiometryAvailable: Bool = false
    @Published var biometryType: LABiometryType = .none
    @Published var areNotificationsAuthorized: Bool = false

    let locationManager = CLLocationManager()

    override init() {
        super.init()
        checkCameraPermission()
        setupLocation()
        checkBiometry()
        checkNotificationPermission()
    }

    // MARK: - Camera
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isCameraAuthorized = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                }
            }
        case .denied, .restricted:
            isCameraAuthorized = false
        @unknown default:
            isCameraAuthorized = false
        }
    }

    // MARK: - Location
    func setupLocation() {
        locationManager.delegate = self
        updateLocationAuthorizationStatus()
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocationAuthorizationStatus()
    }

    private func updateLocationAuthorizationStatus() {
        let status = locationManager.authorizationStatus
        DispatchQueue.main.async {
            self.isLocationAuthorized = (status == .authorizedWhenInUse || status == .authorizedAlways)
        }
    }

    // MARK: - Biometry
    func checkBiometry() {
        let context = LAContext()
        var error: NSError?

        isBiometryAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometryType = context.biometryType
    }

    // MARK: - Notifications
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.areNotificationsAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                self.areNotificationsAuthorized = granted
            }
        }
    }
    
    
    
    // MARK: - Open Settings
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
