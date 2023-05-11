import SwiftUI

struct LoadingView: View {
  let title: String
  
  var body: some View {
    ProgressView(title)
      .multilineTextAlignment(.center)
      .padding(24)
      .background(.ultraThinMaterial)
      .cornerRadius(8)
  }
}

struct LoadingView_Previews: PreviewProvider {
  static var previews: some View {
    LoadingView(title: "Please wait")
  }
}
