//
//  MoonAnimationView.swift
//  fullmoon
//
//  Created by Xavier on 17/12/2024.
//

import AVKit
import SwiftUI

struct PlayerView: UIViewRepresentable {
    var videoName: String

    init(videoName: String) {
        self.videoName = videoName
    }

    func updateUIView(_: UIView, context _: UIViewRepresentableContext<PlayerView>) {}

    func makeUIView(context _: Context) -> UIView {
        return LoopingPlayerUIView(videoName: videoName)
    }
}

class LoopingPlayerUIView: UIView {
    private var playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player = AVQueuePlayer()

    init(videoName: String) {
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: videoName, ofType: "mp4")!)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)

        super.init(frame: .zero)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        
        // Prevent other audio from stopping
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        
        player.play()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}

struct MoonAnimationView: View {
    var isDone: Bool
    
    var body: some View {
        ZStack {
            if isDone {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.green)
            } else {
                // placeholder
                Image(.moonAnimationPlaceholder)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                // video loop
                PlayerView(videoName: "moon-phases")
                    .aspectRatio(contentMode: .fit)
                    .mask {
                        Circle()
                            .scale(0.99)
                    }
            }
        }
        .frame(width: 64, height: 64)
    }
}

#Preview {
    @Previewable @State var done = false
    VStack(spacing: 50) {
        Toggle(isOn: $done, label: { Text("Done") })
        MoonAnimationView(isDone: done)
    }
}
