import Foundation

func combinedIntervals(_ intervals: [CountableClosedRange<Int>]) -> [CountableClosedRange<Int>] {
    var combined = [CountableClosedRange<Int>]()
    var accumulator = (0...0) // empty range

    for interval in intervals.sorted(by: { $0.lowerBound  < $1.lowerBound  }) {
        if accumulator == (0...0) {
            accumulator = interval
        }

        if accumulator.upperBound >= interval.upperBound {
            // interval is already inside accumulator
        } else if accumulator.upperBound >= interval.lowerBound  {
            // interval hangs off the back end of accumulator
            accumulator = (accumulator.lowerBound...interval.upperBound)
        } else if accumulator.upperBound <= interval.lowerBound  {
            // interval does not overlap
            combined.append(accumulator)
            accumulator = interval
        }
    }

    if accumulator != (0...0) {
        combined.append(accumulator)
    }

    return combined
}
