import Foundation
import ComposableArchitecture


extension String: Error { }


struct FactFetcher {
  var fetchFact: @Sendable (String, String) async throws -> String
  
  static let live = Self { number, type in
    guard let url = URL(string: "http://numbersapi.com/\(number)/\(type)") else {
      throw "Invalid URL"
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(decoding: data, as: UTF8.self)
  }
}


private enum FactFetcherKey: DependencyKey {
  static let liveValue = FactFetcher.live
    
  static var previewValue: FactFetcher {
    return .init { _, _ in
      return "1 is an interesting number"
    }
  }
  
}

extension DependencyValues {
  var factFetcher: FactFetcher {
    get { self[FactFetcherKey.self] }
    set { self[FactFetcherKey.self] = newValue }
  }
}
