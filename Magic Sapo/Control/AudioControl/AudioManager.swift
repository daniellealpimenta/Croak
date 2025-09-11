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
    
    private var currentMusicVolume: Float = 0.5
    private var currentSfxVolume: Float = 1.0


    
    static let woodenTap = ["toque-madeira0.m4a", "toque-madeira1.m4a", "toque-madeira2.m4a", "toque-madeira3.m4a"]
    
    private init() {
        applyAudioSettings()
    }
    
    func applyAudioSettings() {
        let isMusicEnabled = UserDefaults.standard.bool(forKey: "isMusicEnabled")
        setMusicMuted(isMuted: !isMusicEnabled)
        
        let isSfxEnabled = UserDefaults.standard.bool(forKey: "isSfxEnabled")
        setSfxMuted(isMuted: !isSfxEnabled)
    }
    
    func setMusicMuted(isMuted: Bool) {
        if isMuted {
            backgroundMusicPlayer?.volume = 0.0
            bossMusicPlayer?.volume = 0.0
        } else {
            backgroundMusicPlayer?.volume = currentMusicVolume
            bossMusicPlayer?.volume = (currentMusicVolume - 0.2) > 0 ? (currentMusicVolume - 0.2) : 0
        }
    }
    
    func setSfxMuted(isMuted: Bool) {
            if isMuted {
                soundEffectVolume = 0.0
            }else {
                soundEffectVolume = currentSfxVolume
            }
        }

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
            
            let isMusicEnabled = UserDefaults.standard.bool(forKey: "isMusicEnabled")
            backgroundMusicPlayer?.volume = isMusicEnabled ? currentMusicVolume : 0.0
            
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
                
                // Aplica o volume correto ao tocar
                let isMusicEnabled = UserDefaults.standard.bool(forKey: "isMusicEnabled")
                let bossVolume = (currentMusicVolume - 0.2) > 0 ? (currentMusicVolume - 0.2) : 0
                bossMusicPlayer?.volume = isMusicEnabled ? bossVolume : 0.0
                
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
        self.currentSfxVolume = max(0.0, min(1.0, volume))
    }
    
    func setMusicVolume(to volume: Float) {
        self.currentMusicVolume = max(0.0, min(1.0, volume))
    }

    func playSoundEffect(named name: String) {
        // A lógica de mutar já está contida no 'soundEffectVolume'
        guard soundEffectVolume > 0, let url = Bundle.main.url(forResource: name, withExtension: nil) else {
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
    var soundEffectVolume: Float = 1.0
    var musicVolume: Float { // Propriedade computada para refletir o estado atual
        get {
            return UserDefaults.standard.bool(forKey: "isMusicEnabled") ? currentMusicVolume : 0.0
        }
        set {
            currentMusicVolume = newValue
        }
    }
}
