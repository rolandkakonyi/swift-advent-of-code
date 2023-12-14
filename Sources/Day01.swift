import Algorithms

struct Day01: AdventDay {
    var data: String

    func part1() -> Any {
        data
            .split(separator: "\n").map {
                $0.map { $0 }
            }
            .compactMap { chars -> Int? in
                guard let firstNumber = chars.first(where: \.isNumber),
                    let lastNumber = chars.last(where: \.isNumber)
                else {
                    return nil
                }

                guard let numberInt = Int("\(firstNumber)\(lastNumber)") else {
                    return nil
                }
                return numberInt
            }
            .reduce(0, +)
    }

    func part2() -> Any {
        let mapping: [String: Character] = [
            "one": "1",
            "two": "2",
            "three": "3",
            "four": "4",
            "five": "5",
            "six": "6",
            "seven": "7",
            "eight": "8",
            "nine": "9",
        ]
        return
            data
            .split(separator: "\n")
            .map { line -> [Character] in
                return line.indices.reduce(into: [Character]()) { partialResult, index in
                    let character = line[index]

                    guard !character.isNumber else {
                        partialResult.append(character)
                        return
                    }

                    let substring = line[index...]

                    for (key, value) in mapping where substring.starts(with: key) {
                        partialResult.append(value)
                    }
                }
            }
            .compactMap { chars -> Int? in
                guard let firstNumber = chars.first(where: \.isNumber),
                    let lastNumber = chars.last(where: \.isNumber)
                else {
                    return nil
                }

                guard let numberInt = Int("\(firstNumber)\(lastNumber)") else {
                    return nil
                }
                return numberInt
            }
            .reduce(0, +)
    }
}
