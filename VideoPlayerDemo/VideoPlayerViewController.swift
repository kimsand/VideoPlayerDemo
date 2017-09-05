//
//  VideoPlayerViewController.swift
//  VideoPlayerDemo
//
//  Created by Kim André Sand on 05/09/2017.
//  Copyright © 2017 Kim André Sand. All rights reserved.
//

import UIKit
import AVFoundation

class VideoPlayerViewController: UIViewController {
	@IBOutlet var buttonStackView: UIStackView!

	let avPlayer = AVPlayer()
	var avPlayerLayer: AVPlayerLayer!

	override func viewDidLoad() {
		super.viewDidLoad()

		// An AVPlayerLayer is a CALayer instance to which the AVPlayer can
		// direct its visual output. Without it, the user will see nothing.
		avPlayerLayer = AVPlayerLayer(player: avPlayer)
		view.layer.insertSublayer(avPlayerLayer, at: 0)

		let url = NSURL(string: "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8")
		let playerItem = AVPlayerItem(url: url! as URL)
		avPlayer.replaceCurrentItem(with: playerItem)
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		// Layout subviews manually
		avPlayerLayer.frame = view.bounds
	}

	func playVideo() {
		let videoIsPlaying = avPlayer.rate > 0

		if videoIsPlaying {
			avPlayer.pause()
		} else {
			avPlayer.play()
		}
	}
}



// MARK: Actions

private extension VideoPlayerViewController {
	@IBAction func playButtonPressed(_ sender: UIButton) {
		playVideo()
	}
}
