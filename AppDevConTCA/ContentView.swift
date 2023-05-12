import SwiftUI
import ComposableArchitecture


struct FactTextFieldDomain: ReducerProtocol {
  struct State: Equatable {
    var title: String
    var value: String = ""
  }
  
  enum Action: Equatable {
    case onTextfieldValueChanged(String)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .onTextfieldValueChanged(let newValue):
          state.value = newValue
          return .none
      }
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
        send: FactTextFieldDomain.Action.onTextfieldValueChanged
      )) {
        Text(viewStore.title)
      }.keyboardType(.numberPad)
    }
  }
}



struct FactTypePickerDomain: ReducerProtocol {
  struct State: Equatable {
    var selectedValue: String = "trivia"
    var types = ["trivia", "math", "year"]
  }
  
  enum Action: Equatable {
    case onPickerValueChanged(String)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
        case .onPickerValueChanged(let newValue):
          state.selectedValue = newValue
          return .none
      }
    }
  }
  
}

struct FactTypePicker: View {
  let store: StoreOf<FactTypePickerDomain>
  
  init(store: StoreOf<FactTypePickerDomain>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(store) { viewStore in
      Picker("Type", selection: viewStore.binding(
        get: \.selectedValue,
        send: FactTypePickerDomain.Action.onPickerValueChanged
      )) {
        ForEach(viewStore.types, id: \.self) { type in
          Text(type.capitalized)
        }
      }
    }
  }
}



struct FactDomain: ReducerProtocol {
  @Dependency(\.factFetcher) var fetcher
  
  struct State: Equatable {
    var fact: String?
    var isLoading = false
    var error: String? = nil
    var textFieldState: FactTextFieldDomain.State
    var pickerState: FactTypePickerDomain.State
  }
  
  enum Action: Equatable {
    case textFieldAction(FactTextFieldDomain.Action)
    case pickerAction(FactTypePickerDomain.Action)
    case onFetchFactButtonTapped
    case onFetchFactResponse(TaskResult<String>)
  }
  
  var body: some ReducerProtocol<State, Action> {
    Scope(state: \.textFieldState, action: /Action.textFieldAction) {
      FactTextFieldDomain()
    }
    Scope(state: \.pickerState, action: /Action.pickerAction) {
      FactTypePickerDomain()
    }
    Reduce { state, action in
      switch action {
        case .onFetchFactButtonTapped:
          state.isLoading = true
          return .task { [
            textFieldValue = state.textFieldState.value,
            selectedPickerValue = state.pickerState.selectedValue
          ] in
            await .onFetchFactResponse(
              TaskResult {
                try await fetcher.fetchFact(textFieldValue, selectedPickerValue)
              }
            )
          }
        case .onFetchFactResponse(.success(let fact)):
          state.fact = fact
          state.isLoading = false
          return .none
        case .onFetchFactResponse(.failure(let error)):
          state.error = error.localizedDescription
          state.isLoading = false
          return .none
        default:
          return .none
      }
    }
  }
  
}



struct ContentView: View {
  let store: StoreOf<FactDomain>
  
  var body: some View {
    NavigationStack {
      WithViewStore(store) { viewStore in
        
        Form {
          Section {
            FactTextField(
              store: store.scope(
                state: \.textFieldState,
                action: FactDomain.Action.textFieldAction
              )
            )
            if let fact = viewStore.fact {
              Text(fact)
            }
          }
          
          Section {
            FactTypePicker(
              store: store.scope(
                state: \.pickerState,
                action: FactDomain.Action.pickerAction
              )
            )
          }
          
          Section {
            Button {
              viewStore.send(.onFetchFactButtonTapped)
            } label: {
              Text("Fetch fact")
            }
            
          }
        }
        .overlay {
          if viewStore.isLoading {
            LoadingView(title: "Fetching the movies\nPlease wait...⏳")
          }
          if let error = viewStore.error {
            ErrorView(error: error) {
              viewStore.send(.onFetchFactButtonTapped)
            }
          }
        }
      }
    }
    
  }
}



struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(store: StoreOf<FactDomain>(
      initialState: .init(
        textFieldState: .init(title: "Please enter a number"),
        pickerState: .init()
      ),
      reducer: FactDomain().dependency(\.factFetcher, .live)
    ))
  }
}
