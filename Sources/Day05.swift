import Algorithms

struct Day05: AdventDay {
    var data: String

    func part1() -> Any {
        let allSections = data
            .split(separator: "\n\n")

        let seeds: [Int] = allSections
            .first?
            .split(separator: ":", maxSplits: 2)
            .last?
            .split(separator: " ")
            .compactMap { Int($0) } ?? []

        let mapSections = allSections.dropFirst()
        let mappings = mapSections.map { parseMapToFunc(section: $0) }

        let seedsToLocation = seeds.map { seed in
            mappings.reduce(seed) { partialResult, mapping in
                mapping(partialResult) ?? partialResult
            }
        }

        guard let minLocation = seedsToLocation.min() else {
            return ""
        }

        return minLocation
    }

    func part2() -> Any {
        let allSections = data
            .split(separator: "\n\n")

        let seedRanges: [CountableClosedRange<Int>] = allSections
            .first?
            .split(separator: ":", maxSplits: 2)
            .last?
            .split(separator: " ")
            .lazy
            .compactMap { Int($0) }
            .chunks(ofCount: 2)
            .reduce(into: []) { partialResult, chunk in
                let start = chunk.first!
                let length = chunk.last!
                let end = start + length - 1
                partialResult.append(start...end)
            }
        ?? []

        let mapSections = allSections.dropFirst()
        let mappings: [[RangeMapping]] = mapSections
            .map { parseMapToRangeMapping(section: $0) }

        func calculateLocation(_ seed: Int) -> Int {
            mappings.reduce(seed) { partialResult, layerMappings in
                mapInput(partialResult, mappings: layerMappings) ?? partialResult
            }
        }

        func mapInput(_ input: Int, mappings: [RangeMapping]) -> Int? {
            for mapping in mappings {
                if let value = mapping.map(input) {
                    return value
                }
            }
            return nil
        }

        func partitionRange(_ inputRange: CountableClosedRange<Int>, mappings: [RangeMapping]) -> [CountableClosedRange<Int>] {
            let validMappings = mappings.filter { mapping in
                mapping.canMap(inputRange)
            }

            assert(validMappings.count <= 1, "Multiple mappings for \(inputRange)")
            if let mapping = validMappings.first {
                // Range has full mapping
                return [mapping.map(inputRange)].compactMap { $0 }
            }

            let partialMappings = mappings.filter { mapping in
                mapping.canPartiallyMap(inputRange)
            }

            guard !partialMappings.isEmpty else {
                return [inputRange]
            }

            guard inputRange.count > 1 else {
                return partitionRange(inputRange, mappings: mappings)
            }

            guard inputRange.count > 2 else {
                return [
                    partitionRange(inputRange.lowerBound...inputRange.lowerBound, mappings: mappings),
                    partitionRange(inputRange.upperBound...inputRange.upperBound, mappings: mappings),
                ]
                .flatMap { $0 }
            }

            let midValue = Int(inputRange.lowerBound + (inputRange.count / 2))
            let leftRange = inputRange.lowerBound...midValue
            let rightRange = (midValue + 1)...inputRange.upperBound

            return [
                partitionRange(leftRange, mappings: mappings),
                partitionRange(rightRange, mappings: mappings),
            ]
            .flatMap { $0 }
        }

        func partitionRanges(
            _ inputRanges: [CountableClosedRange<Int>],
            mappings: [RangeMapping]
        ) -> [CountableClosedRange<Int>] {
            inputRanges.flatMap { inputRange in
                partitionRange(inputRange, mappings: mappings)
            }
        }

        let locationRanges: [CountableClosedRange<Int>] = mappings
            .reduce(seedRanges) { partialResult, layerMappings in
                partitionRanges(partialResult, mappings: layerMappings)
            }

        return locationRanges.map(\.lowerBound).min()!
    }
}

private func parseMapToFunc(
    section: any StringProtocol,
    file: StaticString = #file,
    line: UInt = #line
) -> (Int) -> Int? {
    let mapFunctions:[(Int) -> Int?] = section
        .split(separator: ":\n", maxSplits: 2)
        .last?
        .split(separator: "\n")
        .map { sectionLine -> (Int) -> Int? in
            let components = sectionLine.split(separator: " ")
            guard let destinationRangeStart = Int(components[0]),
                  let sourceRangeStart = Int(components[1]),
                  let length = Int(components[2]) else {
                fatalError("Invalid mapping: \(components)", file: file, line: line)
            }
            return { input in
                let offset: Int = Int(input) - Int(sourceRangeStart)
                guard offset >= 0, offset < length else {
                    return nil
                }
                return destinationRangeStart + offset
            }
        } ?? []

    return { input in
        mapFunctions.reduce(nil) { partialResult, mapping in
            partialResult ?? mapping(input)
        } ?? input
    }
}

private struct RangeMapping {
    var sourceStart: Int
    var destStart: Int
    var length: Int

    var sourceRange: CountableClosedRange<Int> {
        sourceStart...(sourceStart + length - 1)
    }

    var destRange: CountableClosedRange<Int> {
        destStart...(destStart + length - 1)
    }

    func map(_ input: Int) -> Int? {
        let offset = input - sourceStart
        guard offset >= 0, offset < length else {
            return nil
        }
        return destStart + offset
    }

    func map(_ range: CountableClosedRange<Int>) -> CountableClosedRange<Int>? {
        guard let mappedLowerBound = map(range.lowerBound),
              let mappedUpperBound = map(range.upperBound) else {
            return nil
        }
        return mappedLowerBound...mappedUpperBound
    }

    func canMap(_ input: Int) -> Bool {
        let offset = input - sourceStart
        return offset >= 0 && offset < length
    }

    func canMap(_ range: CountableClosedRange<Int>) -> Bool {
        return sourceStart <= range.lowerBound && range.upperBound < sourceStart + length
    }

    func canPartiallyMap(_ range: CountableClosedRange<Int>) -> Bool {
        return sourceRange.overlaps(range)
    }
}

private func parseMapToRangeMapping(section: any StringProtocol, file: StaticString = #file, line: UInt = #line) -> [RangeMapping] {
    section
        .split(separator: ":\n", maxSplits: 2)
        .last?
        .split(separator: "\n")
        .map { sectionLine -> RangeMapping in
            let components = sectionLine.split(separator: " ")
            guard let destinationRangeStart = Int(components[0]),
                  let sourceRangeStart = Int(components[1]),
                  let length = Int(components[2]) else {
                fatalError("Invalid mapping: \(components)", file: file, line: line)
            }

            return RangeMapping(sourceStart: sourceRangeStart, destStart: destinationRangeStart, length: length)
        } ?? []
}
