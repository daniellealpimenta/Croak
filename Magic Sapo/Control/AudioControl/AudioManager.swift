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
    private var fadeTimer: Timer?
    
    private var soundEffectPlayer: AVAudioPlayer?
    var soundEffectVolume: Float = 1.0
    var musicVolume: Float = 0.5

    
    static let woodenTap = ["toque-madeira0.m4a", "toque-madeira1.m4a", "toque-madeira2.m4a", "toque-madeira3.m4a"]
    
    private init() {}

    func playBackgroundMusic(filename: String) {
        
        fadeTimer?.invalidate()
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Erro: Arquivo de áudio não encontrado: \(filename)")
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
            print("Música de fundo iniciada: \(filename)")
        } catch {
            print("Erro ao tentar tocar a música de fundo: \(error.localizedDescription)")
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
                    print("Música de fundo parada com fade-out.")
                }
            }
        }
    
    func pauseBackgroundMusic() {
        if backgroundMusicPlayer?.isPlaying == true {
            backgroundMusicPlayer?.pause()
            print("Música de fundo pausada.")
        }
    }

    func resumeBackgroundMusic() {
        if let player = backgroundMusicPlayer, !player.isPlaying {
            player.play()
            print("Música de fundo retomada.")
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
            print("Erro: Arquivo de efeito sonoro não encontrado: \(name)")
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
            print("Erro: A lista de sons aleatórios está vazia.")
            return
        }
        playSoundEffect(named: randomName)
    }
}
