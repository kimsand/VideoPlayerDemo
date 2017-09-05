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
	@IBOutlet var playButton: UIButton!
	@IBOutlet var bufferSpinner: UIActivityIndicatorView!
	@IBOutlet var bufferSpinnerAlphaView: UIView!

	let avPlayer = AVPlayer()
	var avPlayerLayer: AVPlayerLayer!

	var timeObserver: Any!

	var playerRateBeforeSeek: Float = 0
	var playbackLikelyToKeepUpContext = 0

	deinit {
		avPlayer.removeTimeObserver(timeObserver)
		avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
		NotificationCenter.default.removeObserver(self)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		NotificationCenter.default.addObserver(self, selector: #selector(VideoPlayerViewController.itemDidFinishPlaying(_:)), name:NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)

		bufferSpinnerAlphaView.layer.cornerRadius = 10

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

		avPlayer.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp",
		                     options: .new, context: &playbackLikelyToKeepUpContext)
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
			playButton.setTitle("Play", for: .normal)
		} else {
			avPlayer.play()
			playButton.setTitle("Pause", for: .normal)
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

	fileprivate func restartPlayer() {
		playButton.setTitle("Play", for: .normal)
	}
}



// MARK: Observer

extension VideoPlayerViewController {
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context == &playbackLikelyToKeepUpContext {
			if avPlayer.currentItem!.isPlaybackLikelyToKeepUp {
				bufferSpinner.stopAnimating()
				bufferSpinnerAlphaView.isHidden = true
			} else {
				bufferSpinner.startAnimating()
				bufferSpinnerAlphaView.isHidden = false
			}
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



// MARK: Notifications

extension VideoPlayerViewController {
	func itemDidFinishPlaying(_ notification: Notification) {
		DispatchQueue.main.async {
			self.restartPlayer()
		}
	}
}


