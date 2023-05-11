import SwiftUI

struct ErrorView: View {
  private let error: Error
  private let retryHandler: () -> ()
  
  init(error: Error, retryHandler: @escaping () -> Void) {
    self.error = error
    self.retryHandler = retryHandler
  }
  
  var body: some View {
    VStack(spacing: 8) {
      
      Text("Something wrong happens")
        .font(.title2)
        .fontWeight(.medium)
      
      Text(error.localizedDescription)
        .font(.body)
      
      Button(action: retryHandler) {
        Text("Retry")
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 18)
          .font(.title3.weight(.medium))
          .background(
            Capsule(style: .continuous).foregroundColor(.accentColor)
          )
          .padding(.horizontal, 32)
      }
    }
    .multilineTextAlignment(.center)
    .padding(.vertical, 32)
    .padding(.horizontal, 24)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .padding(.horizontal, 24)
        .foregroundColor(Color(.secondarySystemFill))
    )
  }
}

struct ErrorView_Previews: PreviewProvider {
  static var previews: some View {
    ErrorView(error: "URL not valid") { }
  }
}
