import Algorithms

struct Day03: AdventDay {
    var data: String

    var grid: [[Character]] {
        data
            .split(separator: "\n")
            .map { line in
                line.map { character in
                    character
                }
            }
    }

    func part1() -> Any {
        var numbersToAdd: [Int] = []
        for (y, line) in grid.enumerated() {
            func isInBounds(x: Int, y: Int) -> Bool {
                grid.indices.contains(y) && line.indices.contains(x)
            }
            // print("Checking line: \(line.map(String.init).joined())")
            var buffer = ""
            for (x, character) in line.enumerated() {
                // print("Checking char: \(character) at \(x) x \(y)")
                if character.isNumber {
                    buffer.append(character)
                }

                if !character.isNumber || x == line.count - 1 {
                    if let number = Int(buffer) {
                        let numberLastX = x - 1
                        let numberFirstX = numberLastX - (buffer.count - 1)
                        // print("Found number: \(number) from \(numberFirstX) to \(numberLastX) at \(y)")
                        let positionsToCheck: [(x: Int, y: Int)] = (numberFirstX - 1...numberLastX + 1)
                            .flatMap { posX -> [(x: Int, y: Int)] in
                                (y - 1...y + 1).compactMap { posY -> (x: Int, y: Int)? in
                                    if (numberFirstX...numberLastX).contains(posX), posY == y {
                                        return nil
                                    }
                                    return (posX, posY)
                                }
                            }
                            .filter {
                                isInBounds(x: $0.x, y: $0.y)
                            }
                        var isPartNumber = false
                        for check in positionsToCheck {
                            // print("Checking at: \(check.x) x \(check.y)")
                            if let character = grid[safe: check.y]?[safe: check.x], !isPartNumber {
                                // print("Neighbor character: \(character)")
                                isPartNumber = !character.isNumber && character != "."
                                if isPartNumber {
                                    break
                                }
                            } else {
                                // print("Out of bounds")
                            }
                        }
                        // print("Number: \(number) isPartNumber: \(isPartNumber)")
                        if isPartNumber {
                            numbersToAdd.append(number)
                        }
                    }
                    buffer = ""
                }
            }
        }
        return numbersToAdd.reduce(0, +)
    }

    func part2() -> Any {
        var numbersToAdd: [Int] = []
        var symbolToNumbers: [GridPosition: [Int]] = [:]
        for (y, line) in grid.enumerated() {
            func isInBounds(x: Int, y: Int) -> Bool {
                grid.indices.contains(y) && line.indices.contains(x)
            }
            // print("Checking line: \(line.map(String.init).joined())")
            var buffer = ""
            for (x, character) in line.enumerated() {
                // print("Checking char: \(character) at \(x) x \(y)")
                if character.isNumber {
                    buffer.append(character)
                }

                if !character.isNumber || x == line.count - 1 {
                    if let number = Int(buffer) {
                        let numberLastX = x - 1
                        let numberFirstX = numberLastX - (buffer.count - 1)
                        // print("Found number: \(number) from \(numberFirstX) to \(numberLastX) at \(y)")
                        let positionsToCheck: [GridPosition] = (numberFirstX - 1...numberLastX + 1)
                            .flatMap { posX -> [GridPosition] in
                                (y - 1...y + 1).compactMap { posY -> GridPosition? in
                                    if (numberFirstX...numberLastX).contains(posX), posY == y {
                                        return nil
                                    }
                                    return GridPosition(x: posX, y: posY)
                                }
                            }
                            .filter {
                                isInBounds(x: $0.x, y: $0.y)
                            }
                        var isPartNumber = false
                        for check in positionsToCheck {
                            // print("Checking at: \(check.x) x \(check.y)")
                            if let character = grid[safe: check.y]?[safe: check.x], !isPartNumber {
                                // print("Neighbor character: \(character)")
                                isPartNumber = !character.isNumber && character != "."
                                if isPartNumber {
                                    symbolToNumbers[check, default: []].append(number)
                                    break
                                }
                            } else {
                                // print("Out of bounds")
                            }
                        }
                        // print("Number: \(number) isPartNumber: \(isPartNumber)")
                        if isPartNumber {
                            numbersToAdd.append(number)
                        }
                    }
                    buffer = ""
                }
            }
        }
        return symbolToNumbers.filter { $0.value.count == 2 }.map { $0.value.reduce(1, *) }.reduce(0, +)
    }
}

struct GridPosition: Hashable {
    let x: Int
    let y: Int
}
