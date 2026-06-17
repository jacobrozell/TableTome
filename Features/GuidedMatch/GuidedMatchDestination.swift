import Foundation

enum GuidedMatchDestination: Hashable {
    case playerOne
    case playerTwo
    case battleTracker
    case rollEvaluator
    case unitMatchup
    case step(String)
}
