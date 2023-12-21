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
        let mappings = mapSections.map { parseMap(section: $0) }

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
""
    }
}

func parseMap(section: any StringProtocol, file: StaticString = #file, line: UInt = #line) -> (Int) -> Int? {
    let mapFunctions:[(Int) -> Int?] = section
        .split(separator: ":\n", maxSplits: 2)
        .last?
        .split(separator: "\n")
        .map { sectionLine -> (Int) -> Int? in
            let components = sectionLine.split(separator: " ")
            guard let destinationRangeStart = Int(components[0]),
                  let sourceRangeStart = Int(components[1]),
                  let length = Int(components[2]) else {
                fatalError("Invalid mapping", file: file, line: line)
            }
            return { input in
                let offset = input - sourceRangeStart
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
