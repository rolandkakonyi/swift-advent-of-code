import Algorithms

struct Day04: AdventDay {
    var data: String

    struct Card {
        var id: Int
        var winningNumbers: Set<Int>
        var yourNumbers: Set<Int>
    }

    var cards: [Card] {
        data
            .split(separator: "\n")
            .map { line in
                let idAndRest = line.split(separator: ":")
                guard let id = idAndRest.first?.split(separator: " ").last.flatMap({ Int($0) }),
                      let numbers = idAndRest.last.flatMap(String.init)
                else {
                    fatalError("Could not parse card")
                }

                let winningAndYourNumbers = numbers
                    .split(separator: "|")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                guard let winningNumbers = winningAndYourNumbers.first.flatMap({ $0.split(separator: " ").compactMap { Int($0) } }) else {
                    fatalError("Could not parse winning numbers")
                }

                guard let yourNumbers = winningAndYourNumbers.last.flatMap({ $0.split(separator: " ").compactMap { Int($0) } }) else {
                    fatalError("Could not parse winning numbers")
                }

                return Card(id: id, winningNumbers: Set(winningNumbers), yourNumbers: Set(yourNumbers))
            }
    }

    func part1() -> Any {
        let winningCardPoints = cards.map { card in
            let winningCountOnCard = card.yourNumbers.filter(card.winningNumbers.contains).count
            let cardPoints = 2.pow(toPower: winningCountOnCard - 1)
            return cardPoints

        }
        return winningCardPoints.reduce(0, +)
    }

    func part2() -> Any {
        let parsedCards = cards
        let winningCardIdAndCount: [Int: Int] = parsedCards.reduce(into: [:]) { partialResult, card in
            let winningCountOnCard = card.yourNumbers.filter(card.winningNumbers.contains).count
            partialResult[card.id] = winningCountOnCard
        }
        var cardIdCount: [Int: Int] = parsedCards.reduce(into: [:]) { partialResult, card in
            partialResult[card.id] = 1
        }

        for cardId in cardIdCount.keys.sorted() {
            guard let count = winningCardIdAndCount[cardId] else {
                fatalError("no winning count")
            }
            guard let cardCount = cardIdCount[cardId] else {
                fatalError("no card count")
            }
            for _ in 0..<cardCount {
                for index in 0..<count {
                    let idToIncrease = cardId + index + 1

                    cardIdCount[idToIncrease]? += 1
                }
            }
        }

        return cardIdCount.values.reduce(0, +)
    }
}

extension Int {
    func pow(toPower: Int) -> Int {
        guard toPower >= 0 else { return 0 }
        return Array(repeating: self, count: toPower).reduce(1, *)
    }
}
