import PetriKit

public enum Token: Comparable, ExpressibleByIntegerLiteral {

    case some(UInt)
    case omega

    public init(integerLiteral value: UInt) {
        self = .some(value)
    }

    public static func ==(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case let (.some(x), .some(y)):
            return x == y
        // /!\ REMARK /!\ for assignment correction: in my implementation's logic, default case returning true was not satisfactory and I extended cases checking to
        //                                           include critical scenarios which will 'activate' correct behavior of my implementation's logic.
        case (.some, .omega):
            return false
        case (.omega, .some):
            return false
        case (.omega, .omega):
            return true
        }
    }

    public static func ==(lhs: Token, rhs: UInt) -> Bool {
        return lhs == Token.some(rhs)
    }

    public static func ==(lhs: UInt, rhs: Token) -> Bool {
        return Token.some(lhs) == rhs
    }

    public static func <(lhs: Token, rhs: Token) -> Bool {
        switch (lhs, rhs) {
        case let (.some(x), .some(y)):
            return x < y
        case (_, .omega):
            return true
        default:
            return false
        }
    }

}

extension Dictionary where Key == PTPlace, Value == Token {

    public static func >(lhs: Dictionary, rhs: Dictionary) -> Bool {
        guard lhs.keys == rhs.keys else {
            return false
        }

        var hasGreater = false
        for place in lhs.keys {
            // /!\ REMARK /!\ for assignment correction: the sign should be >= and not <=, I guess? At least in my logic of implementation.
            guard lhs[place]! >= rhs[place]! else { return false }
            if lhs[place]! > rhs[place]! {
                hasGreater = true
            }
        }

        return hasGreater
    }

}

public typealias CoverabilityMarking = [PTPlace: Token]
