import SwiftUI

struct SettingsView: View {
    @AppStorage("isAirMouseEnabled") private var isAirMouseEnabled = false
    @AppStorage("airMouseSensitivity") private var sensitivity = 15.0
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Eksperymentalne")) {
                    Toggle(isOn: $isAirMouseEnabled) {
                        VStack(alignment: .leading) {
                            Text("Tryb Air Mouse")
                                .font(.headline)
                            Text("Steruj kursorem machając telefonem")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isAirMouseEnabled {
                        VStack(alignment: .leading) {
                            Text("Czułość: \(Int(sensitivity))")
                            Slider(value: $sensitivity, in: 5...50, step: 1)
                        }
                    }
                }
                
                Section(header: Text("Info")) {
                    Text("Wersja 1.0 (Beta)")
                }
            }
            .navigationTitle("Ustawienia")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zamknij") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
