import Algorithms

struct Day02: AdventDay {
    struct Game {
        struct GameSet {
            var red: Int
            var green: Int
            var blue: Int
        }

        var id: Int
        var sets: [GameSet]
    }

    var data: String

    let config: (red: Int, green: Int, blue: Int) = (12, 13, 14)

    var games: [Game] {
        data
            .split(separator: "\n")
            .map { line -> Game in
                let parts = line.split(separator: ":")
                guard let idString = parts.first?.split(separator: " ").last,
                    let id = Int(idString)
                else {
                    fatalError("Can't parse ID")
                }
                guard let setsStrings = parts.last?.split(separator: ";") else {
                    fatalError("Can't parse sets")
                }
                let sets = setsStrings.map { setString in
                    let (red, green, blue) = setString.split(separator: ",").map {
                        $0.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .reduce((red: 0, green: 0, blue: 0)) { partialResult, currentValue in
                        var (red, green, blue) = partialResult
                        var buffer = ""
                        for character in currentValue {
                            if character.isNumber {
                                buffer.append(character)
                            } else {

                            }
                        }
                        guard let number = Int(buffer) else {
                            fatalError("Can't parse number")
                        }

                        if currentValue.hasSuffix("red") {
                            red += number
                        } else if currentValue.hasSuffix("green") {
                            green += number
                        } else if currentValue.hasSuffix("blue") {
                            blue += number
                        } else {
                            fatalError("No suffix?")
                        }

                        return (red, green, blue)
                    }
                    return Game.GameSet(red: red, green: green, blue: blue)
                }

                return Game(id: id, sets: sets)
            }
    }

    func part1() -> Any {
        games
            .filter { game in
                game.sets.allSatisfy { set in
                    set.red <= config.red
                        && set.green <= config.green
                        && set.blue <= config.blue
                }
            }
            .map(\.id)
            .reduce(0, +)
    }

    func part2() -> Any {
        games
            .map { game -> Int in
                let (red, green, blue) = game.sets.reduce((red: 0, green: 0, blue: 0)) {
                    partialResult, set in
                    (
                        max(partialResult.red, set.red), max(partialResult.green, set.green),
                        max(partialResult.blue, set.blue)
                    )
                }
                return red * green * blue
            }
            .reduce(0, +)
    }
}
