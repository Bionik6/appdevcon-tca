import SwiftUI
import ComposableArchitecture


class Model: ObservableObject {
  var types = ["trivia", "math", "year"]
  
  @Published var number: String = ""
  @Published var selectedType = "trivia"
  @Published var fact: String?
  @Published var error: Error?
  @Published var isLoading = false
  
  let factFetcher: FactFetcher
  
  init(factFetcher: FactFetcher) {
    self.factFetcher = factFetcher
  }
  
  @MainActor
  func fetchFact() async {
    defer { isLoading = false }
    do {
      isLoading = true
      self.fact = try await factFetcher.fetchFact(number, selectedType)
    } catch {
      self.error = error
    }
  }
}


struct FactTextFieldDomain: ReducerProtocol {
  struct State: Equatable {
    var title: String
    var value: String = ""
  }
  
  enum Action: Equatable {
    case onValueChanged(String)
  }
  
  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
      case .onValueChanged(let newValue):
        state.value = newValue
        return .none
    }
  }
}


struct FactTextField: View {
  let store: StoreOf<FactTextFieldDomain>
  
  init(store: StoreOf<FactTextFieldDomain>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(store) { viewStore in
      TextField(text: viewStore.binding(
        get: \.value,
        send: FactTextFieldDomain.Action.onValueChanged
      )) {
        Text(viewStore.title)
      }.keyboardType(.numberPad)
    }
  }
}











struct ContentView: View {
  @ObservedObject var model: Model
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField(text: $model.number) {
            Text("Please enter a number")
          }.keyboardType(.numberPad)
          if let fact = model.fact {
            Text(fact)
          }
        }
        
        Section {
          Picker("Type", selection: $model.selectedType) {
            ForEach(model.types, id: \.self) { type in
              Text(type.capitalized)
            }
          }
        }
        
        Section {
          Button {
            Task { await model.fetchFact() }
          } label: {
            Text("Fetch fact")
          }
          
        }
      }
      .overlay {
        if model.isLoading {
          LoadingView(title: "Fetching the movies\nPlease wait...⏳")
        }
        if let error = model.error {
          ErrorView(error: error) {
            Task { await model.fetchFact() }
          }
        }
      }
    
    }
    
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(model: .init(factFetcher: .live))
  }
}
