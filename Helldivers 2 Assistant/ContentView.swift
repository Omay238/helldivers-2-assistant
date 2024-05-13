//
//  ContentView.swift
//  Helldivers 2 Assistant
//
//  Created by Leonard Maculo on 4/30/24.
//

import SwiftUI
import SDWebImageSwiftUI
import SDWebImageSVGCoder
import SDWebImageWebPCoder
import SDWebImage
import AVFoundation

struct ContentView: View {
    let timeLimit: Double = 10
    @State var data: Welcome?
    @State var sequence: [Datum] = []
    @State var input: [Key] = []
    @State var round: Int = 0
    @State var score: Int = 0
    @State var perfect: Bool = true
    @State var currentPerfect: Bool = true
    @State var timeRemaining: Double = 10
    @State var state: String = "menu"
    @State var timer: Timer?
    @State var shownNewRound: Int = 0
    @State var resetTimer: Timer?
    
    func createRound() {
        sequence = []
        input = []
        timeRemaining = timeLimit
        perfect = true
        currentPerfect = true
        for _ in 0..<(5+round) {
            sequence.append(self.data!.data.randomElement()!)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Rectangle()
                    .fill(Color.background)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .overlay(
                        VStack {
                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/super_earth.webp"))
                                .resizable()
                                .frame(width: min(geometry.size.width, geometry.size.height) * 0.5, height: min(geometry.size.width, geometry.size.height) * 0.5)
                                .opacity(0.1)
                            Spacer()
                        })
                VStack {
                    HStack {
                        Group {
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                        GlowingText(text: "Round: \(round + 1)")
                        Spacer()
                        GlowingText(text: "Score: \(score)")
                        Group {
                            Spacer()
                            Spacer()
                            Spacer()
                            Spacer()
                        }
                    }
                    Spacer()
                    if state == "main" {
                        if (sequence.count >= 1) {
                            GlowingText(text: sequence[0].name)
                        }
                        ScrollView([], content: {
                            HStack(alignment: .bottom) {
                                ForEach(Array(sequence.enumerated()), id: \.offset) {index, value in
                                    VStack{
                                        WebImage(url: URL(string: value.imageURL))
                                            .resizable()
                                            .frame(width: index == 0 ? 200 : 100, height: index == 0 ? 200 : 100)
                                    }
                                }
                            }
                        })
                        HStack {
                            if sequence.count >= 1 {
                                ForEach(Array(sequence[0].keys.enumerated()), id: \.offset) { index, value in
                                    if input.elementsEqual(sequence[0].keys[0..<min(input.count, sequence[0].keys.count)]) {
                                        (index < input.count ? Color.yellowText : Color.white).mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .rotationEffect(.degrees(Key.getRotation(value: value)))
                                        )
                                        .onChange(of: input.count, {
                                            if sequence[0].keys.count == input.count {
                                                if sequence.count > 1 {
                                                    timeRemaining += 1
                                                    input = []
                                                    if currentPerfect {
                                                        score += 20
                                                    } else {
                                                        score += 10
                                                    }
                                                    Sounds.playSounds(soundfile: "sequence_success.mp3")
                                                    currentPerfect = true
                                                    sequence.removeFirst()
                                                } else {
                                                    state = "newround"
                                                }
                                            }
                                        })
                                    } else {
                                        (index < input.count ? Color.arrowFail : Color.white).mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                                .resizable()
                                                .aspectRatio(1, contentMode: .fit)
                                                .rotationEffect(.degrees(Key.getRotation(value: value)))
                                        ).onAppear(perform: {
                                            resetTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in
                                                input = []
                                                currentPerfect = false
                                                perfect = false
                                            })
                                        })
                                    }
                                }
                            }
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width: geometry.size.width - 40, height: 25)
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.yellow)
                                .frame(width: (geometry.size.width - 40) * (timeRemaining / timeLimit), height: 25)
                        }
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .opacity(0.25)
                                .overlay(
                                    Text("Swipe Here Or Tap Arrow")
                                        .foregroundStyle(.yellowText)
                                        .font(.largeTitle)
                                )
                                .overlay(
                                    VStack {
                                        Color.white.mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                                .rotationEffect(.degrees(270))
                                        )
                                        .onTapGesture {
                                            if sequence.count >= 1 {
                                                if input.count < sequence[0].keys.count {
                                                    if !input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                        resetTimer?.invalidate()
                                                        input = []
                                                        currentPerfect = false
                                                        perfect = false
                                                    }
                                                }
                                            }
                                            input.append(Key.up)
                                            if sequence.count >= 1 {
                                                if input.count < sequence[0].keys.count {
                                                    if input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                        Sounds.playSounds(soundfile: "button_press.mp3")
                                                        Haptics.shared.play(.light)
                                                    } else {
                                                        Sounds.playSounds(soundfile: "button_press_error.mp3")
                                                        Haptics.shared.play(.rigid)
                                                    }
                                                }
                                            }
                                        }
                                        Spacer()
                                        HStack {
                                            Color.white.mask(
                                                WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                                    .rotationEffect(.degrees(180))
                                            )
                                            .onTapGesture {
                                                if sequence.count >= 1 {
                                                    if input.count < sequence[0].keys.count {
                                                        if !input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                            resetTimer?.invalidate()
                                                            input = []
                                                            currentPerfect = false
                                                            perfect = false
                                                        }
                                                    }
                                                }
                                                input.append(Key.keyLeft)
                                                if sequence.count >= 1 {
                                                    if input.count < sequence[0].keys.count {
                                                        if input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                            Sounds.playSounds(soundfile: "button_press.mp3")
                                                            Haptics.shared.play(.light)
                                                        } else {
                                                            Sounds.playSounds(soundfile: "button_press_error.mp3")
                                                            Haptics.shared.play(.rigid)
                                                        }
                                                    }
                                                }
                                            }
                                            Spacer()
                                            Color.white.mask(
                                                WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                            )
                                            .onTapGesture {
                                                if sequence.count >= 1 {
                                                    if input.count < sequence[0].keys.count {
                                                        if !input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                            resetTimer?.invalidate()
                                                            input = []
                                                            currentPerfect = false
                                                            perfect = false
                                                        }
                                                    }
                                                }
                                                input.append(Key.keyRight)
                                                if sequence.count >= 1 {
                                                    if input.count < sequence[0].keys.count {
                                                        if input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                            Sounds.playSounds(soundfile: "button_press.mp3")
                                                            Haptics.shared.play(.light)
                                                        } else {
                                                            Sounds.playSounds(soundfile: "button_press_error.mp3")
                                                            Haptics.shared.play(.rigid)
                                                        }
                                                    }
                                                }
                                            }
                                            .ignoresSafeArea()
                                        }
                                        Spacer()
                                        Color.white.mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                                .rotationEffect(.degrees(90))
                                        )
                                        .onTapGesture {
                                            if sequence.count >= 1 {
                                                if input.count < sequence[0].keys.count {
                                                    if !input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                        resetTimer?.invalidate()
                                                        input = []
                                                        currentPerfect = false
                                                        perfect = false
                                                    }
                                                }
                                            }
                                            input.append(Key.down)
                                            if sequence.count >= 1 {
                                                if input.count < sequence[0].keys.count {
                                                    if input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                        Sounds.playSounds(soundfile: "button_press.mp3")
                                                        Haptics.shared.play(.light)
                                                    } else {
                                                        Sounds.playSounds(soundfile: "button_press_error.mp3")
                                                        Haptics.shared.play(.rigid)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                        .frame(width: geometry.size.width * 1.5)
                                )
                                .frame(width: geometry.size.width - 40, height: geometry.size.height * 0.5)
                                .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                    .onEnded({ value in
                                        if sequence.count >= 1 {
                                            if input.count < sequence[0].keys.count {
                                                if !input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                    resetTimer?.invalidate()
                                                    input = []
                                                    currentPerfect = false
                                                    perfect = false
                                                }
                                            }
                                        }
                                        if abs(value.translation.width) == max(abs(value.translation.width), abs(value.translation.height)) {
                                            if value.translation.width > 0 {
                                                input.append(Key.keyRight)
                                            } else {
                                                input.append(Key.keyLeft)
                                            }
                                        }
                                        if abs(value.translation.height) == max(abs(value.translation.width), abs(value.translation.height)) {
                                            if value.translation.height > 0 {
                                                input.append(Key.down)
                                            } else {
                                                input.append(Key.up)
                                            }
                                        }
                                        if sequence.count >= 1 {
                                            if input.count < sequence[0].keys.count {
                                                if input.elementsEqual(sequence[0].keys[0..<input.count]) {
                                                    Sounds.playSounds(soundfile: "button_press.mp3")
                                                    Haptics.shared.play(.light)
                                                } else {
                                                    Sounds.playSounds(soundfile: "button_press_error.mp3")
                                                    Haptics.shared.play(.rigid)
                                                }
                                            }
                                        }
                                    }
                                            )
                                )
                        }
                    } else if state == "menu" {
                        RoundedRectangle(cornerRadius: 25)
                            .opacity(0.25)
                            .overlay(
                                Text("Swipe Or Tap Arrow To Start")
                                    .foregroundStyle(.yellowText)
                                    .font(.largeTitle)
                            )
                            .overlay(
                                VStack {
                                    Color.white.mask(
                                        WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                            .rotationEffect(.degrees(270))
                                    )
                                    .onTapGesture {
                                        timeRemaining = timeLimit
                                        state = "main"
                                        Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                    }
                                    Spacer()
                                    HStack {
                                        Color.white.mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                                .rotationEffect(.degrees(180))
                                        )
                                        .onTapGesture {
                                            timeRemaining = timeLimit
                                            state = "main"
                                            Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                        }
                                        Spacer()
                                        Color.white.mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                        )
                                        .onTapGesture {
                                            timeRemaining = timeLimit
                                            state = "main"
                                            Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                        }
                                        .ignoresSafeArea()
                                    }
                                    Spacer()
                                    Color.white.mask(
                                        WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                            .rotationEffect(.degrees(90))
                                    )
                                    .onTapGesture {
                                        timeRemaining = timeLimit
                                        state = "main"
                                        Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                    }
                                }
                                    .frame(width: geometry.size.width * 1.5)
                            )
                            .frame(width: geometry.size.width - 40, height: geometry.size.height * 0.5)
                            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                .onEnded({ value in
                                    timeRemaining = timeLimit
                                    state = "main"
                                    Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                }))
                    } else if state == "newround" {
                        VStack {
                            Spacer()
                            Text("")
                                .onAppear(perform: {
                                    Sounds.playSounds(soundfile: "round_over.mp3")
                                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
                                        shownNewRound += 1
                                    })
                                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in
                                        shownNewRound += 1
                                    })
                                    Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false, block: {_ in
                                        shownNewRound += 1
                                    })
                                    Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false, block: {_ in
                                        shownNewRound += 1
                                        score = score + (75 + 25 * round) + Int(timeRemaining / timeLimit * 100) + (perfect ? 100 : 0)
                                        round += 1
                                    })
                                    Timer.scheduledTimer(withTimeInterval: 4, repeats: false, block: {_ in
                                        shownNewRound = 0
                                        Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                        createRound()
                                        state = "main"
                                    })
                                })
                            if shownNewRound >= 1 {
                                GlowingText(text: "Round Bonus: \(75 + 25 * round)")
                            }
                            if shownNewRound >= 2 {
                                GlowingText(text: "Time Bonus: \(Int(timeRemaining / timeLimit * 100))")
                            }
                            if shownNewRound >= 3 {
                                GlowingText(text: "Perfect Bonus: \(perfect ? 100 : 0)")
                            }
                            if shownNewRound >= 4 {
                                GlowingText(text: "Total Score: \(score)")
                            }
                            Spacer()
                        }
                    } else if state == "end" {
                        GlowingText(text: "Your Score: \(score)")
                            .onAppear {
                                Sounds.playSounds(soundfile: "game_over.mp3")
                            }
                        RoundedRectangle(cornerRadius: 25)
                            .opacity(0.25)
                            .overlay(
                                Text("Swipe Or Tap Arrow To Restart")
                                    .foregroundStyle(.yellowText)
                                    .font(.largeTitle)
                            )
                            .overlay(
                                VStack {
                                    Color.white.mask(
                                        WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                            .rotationEffect(.degrees(270))
                                    )
                                    .onTapGesture {
                                        timeRemaining = timeLimit
                                        state = "main"
                                        sequence = []
                                        createRound()
                                        input = []
                                        round = 0
                                        score = 0
                                        perfect = true
                                        currentPerfect = true
                                        Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                    }
                                    Spacer()
                                    HStack {
                                        Color.white.mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                                .rotationEffect(.degrees(180))
                                        )
                                        .onTapGesture {
                                            timeRemaining = timeLimit
                                            state = "main"
                                            sequence = []
                                            createRound()
                                            input = []
                                            round = 0
                                            score = 0
                                            perfect = true
                                            currentPerfect = true
                                            Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                        }
                                        Spacer()
                                        Color.white.mask(
                                            WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                        )
                                        .onTapGesture {
                                            timeRemaining = timeLimit
                                            state = "main"
                                            sequence = []
                                            createRound()
                                            input = []
                                            round = 0
                                            score = 0
                                            perfect = true
                                            currentPerfect = true
                                            Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                        }
                                        .ignoresSafeArea()
                                    }
                                    Spacer()
                                    Color.white.mask(
                                        WebImage(url: URL(string: "https://github.com/byjokese/stratagem-hero/raw/main/src/assets/arrow.svg"))
                                            .rotationEffect(.degrees(90))
                                    )
                                    .onTapGesture {
                                        timeRemaining = timeLimit
                                        state = "main"
                                        sequence = []
                                        createRound()
                                        input = []
                                        round = 0
                                        score = 0
                                        perfect = true
                                        currentPerfect = true
                                        Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                    }
                                }
                                    .frame(width: geometry.size.width * 1.5)
                            )
                            .frame(width: geometry.size.width - 40, height: geometry.size.height * 0.5)
                            .gesture(DragGesture(minimumDistance: 20, coordinateSpace: .local)
                                .onEnded({ value in
                                    Sounds.playSounds(soundfile: "round_start_coin.mp3")
                                    timeRemaining = timeLimit
                                    state = "main"
                                    sequence = []
                                    createRound()
                                    input = []
                                    round = 0
                                    score = 0
                                    perfect = true
                                    currentPerfect = true
                                }))
                    }
                }
            }
        }
        .onAppear(perform: {
            SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
            SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
            if let url = URL(string: "https://rapidly-ruling-baboon.ngrok-free.app/api/stratagems?limit=500") {
                fetchJSON(from: url) { result in
                    switch result {
                    case .success(let welcome):
                        self.data = welcome
                        createRound()
                        let imageURLs = welcome.data.map { URL(string: $0.imageURL) }.compactMap { $0 }
                        SDWebImagePrefetcher.shared.prefetchURLs(imageURLs)
                    case .failure(_): break
                    }
                }
            }
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                if state == "main" {
                    timeRemaining -= 0.01
                    if timeRemaining <= 0 {
                        state = "end"
                    }
                }
            }
        })
    }
}

struct GlowingText: View {
    let text: String
    var body: some View {
        ZStack {
            Text(text)
                .foregroundStyle(.yellowText)
                .font(.largeTitle)
                .blur(radius: 10)
            Text(text)
                .foregroundStyle(.yellowText)
                .font(.largeTitle)
                .blur(radius: 6)
            Text(text)
                .foregroundStyle(.yellowText)
                .font(.largeTitle)
                .blur(radius: 2)
            Text(text)
                .foregroundStyle(.yellowText)
                .font(.largeTitle)
        }
    }
}

#Preview {
    ContentView()
}
