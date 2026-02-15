import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    let onLocationGranted: () -> Void
    let onUseDefaultLocation: () -> Void
    let onZipCodeEntered: (String) -> Void
    
    @State private var zipCode = ""
    @FocusState private var isZipCodeFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Location icon
            Image(systemName: "location.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
            
            // Title
            Text("Find Restaurants Near You")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Description
            Text("We need your location to show you the best restaurants in your area. Your location is only used to find nearby restaurants and is never shared.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                .padding(.horizontal)
            
            // Permission button
            Button(action: {
                requestLocationPermission()
            }) {
                HStack {
                    Image(systemName: "location.fill")
                    Text("Enable Location Access")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.1, green: 0.2, blue: 0.4))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            

            
            // Zip code input option
            VStack(spacing: 8) {
                Text("Or enter a zip code:")
                    .font(.caption)
                    .foregroundColor(Color(red: 0.3, green: 0.4, blue: 0.5))
                
                HStack {
                    TextField("Enter zip code", text: $zipCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 120)
                        .focused($isZipCodeFieldFocused)
                        .onSubmit {
                            if !zipCode.isEmpty {
                                print("🔧 Go button tapped with zip code: \(zipCode)")
                                print("🔧 Calling onZipCodeEntered callback")
                                onZipCodeEntered(zipCode)
                                print("🔧 onZipCodeEntered callback completed")
                            }
                        }
                        .onTapGesture {
                            print("🔧 TextField tapped - setting focus to true")
                            DispatchQueue.main.async {
                                isZipCodeFieldFocused = true
                            }
                        }
                        .onAppear {
                            print("🔧 TextField appeared - setting focus")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isZipCodeFieldFocused = true
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .keyboard) {
                                HStack {
                                    Spacer()
                                    Button("Done") {
                                        isZipCodeFieldFocused = false
                                    }
                                }
                            }
                        }
                    
                    Button(action: {
                        if !zipCode.isEmpty {
                            print("🔧 Go button tapped with zip code: \(zipCode)")
                            print("🔧 Calling onZipCodeEntered callback")
                            onZipCodeEntered(zipCode)
                            print("🔧 onZipCodeEntered callback completed")
                        } else {
                            print("🔧 Go button tapped but zip code is empty")
                        }
                    }) {
                        Text("Go")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(zipCode.isEmpty ? Color.gray : Color(red: 0.1, green: 0.2, blue: 0.4))
                            .cornerRadius(8)
                    }
                    .disabled(zipCode.isEmpty)
                }
            }
            .padding(.top, 8)
            
            Spacer()
        }
        .padding()
    }
    
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        
        // Check current status first
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            // Permission was denied, open Settings
            print("🔐 Permission denied - opening Settings")
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        case .notDetermined:
            // Request permission
            print("🔐 Requesting permission...")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Already authorized
            print("🔐 Already authorized")
            onLocationGranted()
        @unknown default:
            print("❓ Unknown authorization status")
            break
        }
    }
}

#Preview {
    LocationPermissionView(
        onLocationGranted: {},
        onUseDefaultLocation: {},
        onZipCodeEntered: { _ in }
    )
} 