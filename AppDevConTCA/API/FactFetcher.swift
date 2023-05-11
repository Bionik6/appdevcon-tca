import Foundation

extension String: Error { }

struct FactFetcher {
  var fetchFact: (String, String) async throws -> String
  
  init(fetchFact: @escaping (String, String) async throws -> String) {
    self.fetchFact = fetchFact
  }
  
  static let live = Self { number, type in
    guard let url = URL(string: "http://numbersapi.com/\(number)/\(type)") else {
      throw "Invalid URL"
    }
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(decoding: data, as: UTF8.self)
  }
}
