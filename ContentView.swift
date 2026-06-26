import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var formula = "t*(t>>12|t>>8)&63&t>>4"
    @State private var isPlaying = false
    @State private var sampleRate: Double = 8000
    @State private var engine = AVAudioEngine()
    @State private var sourceNode: AVAudioSourceNode?
    var body: some View {
        VStack(spacing: 24) {
            TextEditor(text: $formula)
                .font(.system(.body, design: .monospaced))
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .frame(height: 200)
            Picker("Taajuus", selection: $sampleRate) {
                Text("8 kHz").tag(8000.0)
                Text("11 kHz").tag(11025.0)
                Text("22 kHz").tag(22050.0)
                Text("44.1 kHz").tag(44100.0)
            }
            .pickerStyle(SegmentedPickerStyle())
            Button(action: {
                if isPlaying {
                    stopAudio()
                } else {
                    startAudio()
                }
            }) {
                Text(isPlaying ? "Seis" : "Soita")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isPlaying ? Color.red : Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
    func startAudio() {
        let evaluator = BytebeatEvaluator(formula: formula)
        var currentT: UInt32 = 0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            if let buffer = abl[0].mData?.assumingMemoryBound(to: Float.self) {
                for frame in 0..<Int(frameCount) {
                    let val = evaluator.evaluate(t: Int(currentT))
                    buffer[frame] = Float((val & 0xFF) - 128) / 128.0
                    currentT &+= 1
                }
            }
            return noErr
        }
        engine.attach(sourceNode!)
        engine.connect(sourceNode!, to: engine.mainMixerNode, format: format)
        do {
            try engine.start()
            isPlaying = true
        } catch {
            print(error)
        }
    }
    func stopAudio() {
        engine.stop()
        if let node = sourceNode {
            engine.detach(node)
        }
        sourceNode = nil
        isPlaying = false
    }
}
