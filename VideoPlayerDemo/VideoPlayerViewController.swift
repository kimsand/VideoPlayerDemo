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
	@IBOutlet var timeRemainingLabel: UILabel!
	@IBOutlet var seekSlider: UISlider!

	let avPlayer = AVPlayer()
	var avPlayerLayer: AVPlayerLayer!

	var timeObserver: Any!

	var playerRateBeforeSeek: Float = 0

	deinit {
		avPlayer.removeTimeObserver(timeObserver)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// An AVPlayerLayer is a CALayer instance to which the AVPlayer can
		// direct its visual output. Without it, the user will see nothing.
		avPlayerLayer = AVPlayerLayer(player: avPlayer)
		view.layer.insertSublayer(avPlayerLayer, at: 0)

		let url = NSURL(string: "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8")
		let playerItem = AVPlayerItem(url: url! as URL)
		avPlayer.replaceCurrentItem(with: playerItem)

		let timeInterval: CMTime = CMTimeMakeWithSeconds(1.0, 10)
		timeObserver = avPlayer
			.addPeriodicTimeObserver(forInterval: timeInterval,
			                         queue: DispatchQueue.main) {
										(elapsedTime: CMTime) -> Void in

										self.observeTime(elapsedTime: elapsedTime)
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		// Layout subviews manually
		avPlayerLayer.frame = view.bounds
	}

	fileprivate func playVideo() {
		let videoIsPlaying = avPlayer.rate > 0

		if videoIsPlaying {
			avPlayer.pause()
		} else {
			avPlayer.play()
		}
	}

	fileprivate func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
		let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
		timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
	}

	private func observeTime(elapsedTime: CMTime) {
		let duration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
		if duration.isFinite {
			let elapsedTime = CMTimeGetSeconds(elapsedTime)
			updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
		}
	}
}



// MARK: Actions

private extension VideoPlayerViewController {
	@IBAction func playButtonPressed(_ sender: UIButton) {
		playVideo()
	}

	@IBAction func sliderBeganTracking(slider: UISlider) {
		playerRateBeforeSeek = avPlayer.rate
		avPlayer.pause()
	}

	@IBAction func sliderEndedTracking(slider: UISlider) {
		let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
		let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
		updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)

		avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) {
			(completed: Bool) -> Void in
			if self.playerRateBeforeSeek > 0 {
				self.avPlayer.play()
			}
		}
	}

	@IBAction func sliderValueChanged(slider: UISlider) {
		let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
		let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
		updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
	}
}


