//
//  AudioManager.swift
//  Magic Sapo
//
//  Created by Daniel Leal PImenta on 05/09/25.
//

import AVFoundation
import SpriteKit

class AudioManager {

    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var bossMusicPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    
    private var soundEffectPlayer: AVAudioPlayer?
    var soundEffectVolume: Float = 1.0
    var musicVolume: Float = 0.5

    
    static let woodenTap = ["toque-madeira0.m4a", "toque-madeira1.m4a", "toque-madeira2.m4a", "toque-madeira3.m4a"]
    
    private init() {}

    func playBackgroundMusic(filename: String) {
        
        fadeTimer?.invalidate()
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            return
        }
        
        do {
            if backgroundMusicPlayer?.isPlaying == true {
                backgroundMusicPlayer?.stop()
            }

            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = musicVolume
            backgroundMusicPlayer?.prepareToPlay()
            backgroundMusicPlayer?.play()
        } catch {
            print("Erro ao tentar tocar a música de fundo: \(error.localizedDescription)")
        }
    }
    
    func playBossMusic(_ filename: String = "boss-music.m4a") {
        
        fadeTimer?.invalidate()
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            return
        }
        
        do {
            if bossMusicPlayer?.isPlaying == true {
                bossMusicPlayer?.stop()
            }

            bossMusicPlayer = try AVAudioPlayer(contentsOf: url)
            bossMusicPlayer?.numberOfLoops = -1
            bossMusicPlayer?.volume = (musicVolume - 0.2) 
            bossMusicPlayer?.prepareToPlay()
            bossMusicPlayer?.play()
        } catch {
            print("Erro ao tentar tocar a música de fundo: \(error.localizedDescription)")
        }
    }

    func stopBossMusic(fadeOutDuration: TimeInterval = 1.2) {
            guard let player = bossMusicPlayer, player.isPlaying else { return }

            let fadeInterval: TimeInterval = 0.15 // A frequência com que o volume é atualizado
            let initialVolume = player.volume
            // Calcula quanto o volume deve diminuir a cada passo do timer
            let volumeStep = initialVolume / Float(fadeOutDuration / fadeInterval)

            // Invalida qualquer timer anterior para garantir que não haja sobreposição
            fadeTimer?.invalidate()

            fadeTimer = Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { [weak self] timer in
                guard let self = self, let player = self.bossMusicPlayer else {
                    timer.invalidate()
                    return
                }

                // Diminui o volume
                player.volume -= volumeStep

                // Se o volume chegar a zero (ou menos), para a música e o timer
                if player.volume <= 0 {
                    player.stop()
                    player.volume = initialVolume // Reseta o volume para a próxima vez que tocar
                    self.fadeTimer?.invalidate()
                    self.fadeTimer = nil
                }
            }
        }
    
    func pauseBossMusic() {
        if bossMusicPlayer?.isPlaying == true {
            bossMusicPlayer?.pause()
        }
    }

    func resumeBossMusic() {
        if let player = bossMusicPlayer, !player.isPlaying {
            player.play()
        }
    }

    func stopBackgroundMusic(fadeOutDuration: TimeInterval = 2.0) {
            guard let player = backgroundMusicPlayer, player.isPlaying else { return }

            let fadeInterval: TimeInterval = 0.1 // A frequência com que o volume é atualizado
            let initialVolume = player.volume
            // Calcula quanto o volume deve diminuir a cada passo do timer
            let volumeStep = initialVolume / Float(fadeOutDuration / fadeInterval)

            // Invalida qualquer timer anterior para garantir que não haja sobreposição
            fadeTimer?.invalidate()

            fadeTimer = Timer.scheduledTimer(withTimeInterval: fadeInterval, repeats: true) { [weak self] timer in
                guard let self = self, let player = self.backgroundMusicPlayer else {
                    timer.invalidate()
                    return
                }

                // Diminui o volume
                player.volume -= volumeStep

                // Se o volume chegar a zero (ou menos), para a música e o timer
                if player.volume <= 0 {
                    player.stop()
                    player.volume = initialVolume // Reseta o volume para a próxima vez que tocar
                    self.fadeTimer?.invalidate()
                    self.fadeTimer = nil
                }
            }
        }
    
    func pauseBackgroundMusic() {
        if backgroundMusicPlayer?.isPlaying == true {
            backgroundMusicPlayer?.pause()
        }
    }

    func resumeBackgroundMusic() {
        if let player = backgroundMusicPlayer, !player.isPlaying {
            player.play()
        }
    }

    func setSoundEffectVolume(to volume: Float) {
        self.soundEffectVolume = max(0.0, min(1.0, volume))
    }
    
    func setMusicVolume(to volume: Float) {
        self.musicVolume = max(0.0, min(1.0, volume))
    }

    func playSoundEffect(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
            return
        }

        do {
            soundEffectPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayer?.volume = self.soundEffectVolume
            soundEffectPlayer?.play()
        } catch {
            print("Erro ao tocar efeito sonoro: \(error.localizedDescription)")
        }
    }
    
    func playRandomSoundEffect(from names: [String]) {
        guard let randomName = names.randomElement() else {
            return
        }
        playSoundEffect(named: randomName)
    }
}
