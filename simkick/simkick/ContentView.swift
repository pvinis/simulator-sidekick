import SwiftUI


struct ContentView: View {
    @StateObject private var state = SimulatorState()
	@State private var refreshDebouncer = Debouncer(delay: 1.5)

    var body: some View {
        VStack(spacing: 20) {
			Text("Simulator Sidekick")
				.font(.headline)
				.padding(.top)

			Spacer()

			Button(action: {
				SimulatorCommands.triggerFaceIDMatch()
			}) {
				VStack(spacing: 8) {
					Image(systemName: "faceid")
						.font(.largeTitle)
					Text("Face ID Match").font(.subheadline)
				}
				.foregroundColor(.blue)
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(Color.blue.opacity(0.1))
						.stroke(Color.blue, lineWidth:1)
				)
			}
			.buttonStyle(PlainButtonStyle())
			.help("Triggers Face ID matching face")

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: state.appearance == .dark ? "moon.fill" : "sun.max.fill")
                        .font(.title2)
                        .foregroundColor(.orange)

                    Text("Dark Mode")
                        .font(.subheadline)

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { state.isDarkMode },
                        set: { newValue in
                            SimulatorCommands.setAppearance(newValue ? .dark : .light)
                            state.appearance = newValue ? .dark : .light
                            refreshDebouncer.schedule {
                                state.appearance = SimulatorCommands.getCurrentAppearance()
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle())
                    .labelsHidden()
                }
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 12)
						.fill(Color.orange.opacity(0.1))
						.stroke(Color.orange, lineWidth: 1)
				)
			}
			.help("Toggle simulator appearance between dark and light mode")

			Spacer()

            Text("more tools here")
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            state.appearance = SimulatorCommands.getCurrentAppearance()
        }
    }
}




#Preview {
    ContentView()
		.frame(width: 200, height: 600)
}

// TODO: add gh actions to build
// TODO: host this somewhere
// TODO: add to brew
// TODO: add to sparkle

