//from NSHipster - http://nshipster.com/swift-literal-convertible/
public struct Regex {
    let pattern: String
    let options: NSRegularExpression.Options!

    private var matcher: NSRegularExpression {
        // swiftlint:disable:next force_try
        return try! NSRegularExpression(pattern: self.pattern, options: self.options)
        // swiftlint:disable:previous force_try
    }

    public init(pattern: String, options: NSRegularExpression.Options = []) {
        self.pattern = pattern
        self.options = options
    }

    public func match(string: String, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        return self.matcher.numberOfMatches(
            in: string, options: options,
            range: NSMakeRange(0, string.utf16.count) //swiftlint:disable:this legacy_constructor
        ) != 0
    }
}

//from Les Stroud http://www.lesstroud.com/swift-using-regex-in-switch-statements/
public protocol RegularExpressionMatchable {
    func match(regex: Regex) -> Bool
}

//from Les Stroud http://www.lesstroud.com/swift-using-regex-in-switch-statements/
extension String: RegularExpressionMatchable {
    public func match(regex: Regex) -> Bool {
        return regex.match(string: self)
    }
}

//from Les Stroud http://www.lesstroud.com/swift-using-regex-in-switch-statements/
public func ~=<T: RegularExpressionMatchable>(pattern: Regex, matchable: T) -> Bool {
    return matchable.match(regex: pattern)
}
