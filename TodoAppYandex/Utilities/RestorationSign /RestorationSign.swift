import SwiftUI

struct RestorationSignView: View {

    let dateString: String

    var body: some View {
        VStack {

            Text("Эта часть приложения ремонируется")
                .multilineTextAlignment(.center)
                .font(.title3)
                .fontWeight(.semibold)

            Image(systemName: "wrench.adjustable.fill")
                .font(.largeTitle)
                .padding()

            VStack {
                Text("Примерная дата завершения:")
                    .fontWeight(.semibold)
                Text(dateString)

            }
            .font(.caption)
            .multilineTextAlignment(.center)

        }
        .padding()
        .frame(width: 240, height: 240)
        .background {
            TransparentBlurView(removeAllFilters: true)
                .blur(radius: 9, opaque: true)
                .background(.gray.opacity((0.15)))
        }
        .clipShape(.rect(cornerRadius: 15, style: .continuous))
    }
}
