import SwiftUI
import AVFoundation
import Photos
import UserNotifications
import CoreLocation

struct PreferencesView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var locationService: LocationService
    
    @State private var cameraStatus: AVAuthorizationStatus = .notDetermined
    @State private var photoStatus: PHAuthorizationStatus = .notDetermined
    @State private var notificationsAllowed: Bool? = nil
    @State private var locationStatus: CLAuthorizationStatus = .notDetermined

    var body: some View {
        ZStack {
            Color(colorScheme == .dark ? Color.backgroundColorDark : Color.lightColorApp)
                .ignoresSafeArea()
            List {
                Section(header: Text("App Permissions")) {
                    
                    HStack {
                        Label("Camera", systemImage: "camera")
                        Spacer()
                        Text(describe(status: cameraStatus))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Label("Photo Library", systemImage: "photo.on.rectangle")
                        Spacer()
                        Text(describe(status: photoStatus))
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Label("Notifications", systemImage: "bell")
                        Spacer()
                        Text(notificationsAllowedText)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Label("Location", systemImage: "location")
                        Spacer()
                        Text(describe(status: locationStatus))
                            .foregroundColor(.secondary)
                    }
                }
                Section {
                    Button {
                        openAppSettings()
                    } label: {
                        Label("Manage Permissions", systemImage: "gearshape")
                            .foregroundColor(Color.terracotta)
                    }
                }
            }
        }
        .onAppear {
            updatePermissions()
        }
        .customNavigationTitle("Preferences")
    }

    var notificationsAllowedText: String {
        if let allowed = notificationsAllowed {
            return allowed ? "Allowed" : "Denied"
        } else {
            return "Checking..."
        }
    }

    func describe(status: AVAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Allowed"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }

    func describe(status: PHAuthorizationStatus) -> String {
        switch status {
        case .authorized, .limited: return "Allowed"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }

    func describe(status: CLAuthorizationStatus) -> String {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse: return "Allowed"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }

    func updatePermissions() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoStatus = PHPhotoLibrary.authorizationStatus()

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                notificationsAllowed = settings.authorizationStatus == .authorized
            }
        }

        locationStatus = CLLocationManager().authorizationStatus
    }
    func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
