import ComposableArchitecture
import SwiftUI

private let readMe = """
  This demonstrates how to best handle alerts and action sheets in the Composable Architecture.

  Because the library demands that all data flow through the application in a single direction, \
  we cannot leverage SwiftUI's two-way bindings because they can make changes to state without \
  going through a reducer. This means we can't directly use the standard API to display alerts and \
  sheets.

  However, the library comes with two types, `AlertState` and `ActionSheetState`, which can be \
  constructed from reducers and control whether or not an alert or action sheet is displayed. \
  Further, it automatically handles sending actions when you tap their buttons, which allows you \
  to properly handle their functionality in the reducer rather than in two-way bindings and action \
  closures.

  The benefit of doing this is that you can get full test coverage on how a user interacts with \
  with alerts and action sheets in your application
  """

struct AlertAndSheetState: Equatable {
  var actionSheet = ActionSheetState<AlertAndSheetAction>.dismissed
  var alert = AlertState<AlertAndSheetAction>.dismissed
  var count = 0
}

enum AlertAndSheetAction: Equatable {
  case actionSheetButtonTapped
  case actionSheetCancelTapped
  case alertButtonTapped
  case alertCancelTapped
  case decrementButtonTapped
  case incrementButtonTapped
}

struct AlertAndSheetEnvironment {}

let AlertAndSheetReducer = Reducer<
  AlertAndSheetState, AlertAndSheetAction, AlertAndSheetEnvironment
> { state, action, _ in

  switch action {
  case .actionSheetButtonTapped:
    state.actionSheet = .show(
      .init(
        buttons: [
          .init(
            action: .actionSheetCancelTapped,
            label: "Cancel",
            type: .cancel
          ),
          .init(
            action: .incrementButtonTapped,
            label: "Increment"
          ),
          .init(
            action: .decrementButtonTapped,
            label: "Decrement"
          ),
        ],
        message: "This is an action sheet.",
        title: "Action sheet"
      )
    )
    return .none

  case .actionSheetCancelTapped:
    state.actionSheet = .dismissed
    return .none

  case .alertButtonTapped:
    state.alert = .show(
      .init(
        title: "Alert!",
        message: "This is an alert",
        primaryButton: .cancel(
          "Cancel",
          send: .alertCancelTapped
        ),
        secondaryButton: .default(
          "Increment",
          send: .incrementButtonTapped
        )
      )
    )
    return .none

  case .alertCancelTapped:
    state.alert = .dismissed
    return .none

  case .decrementButtonTapped:
    state.actionSheet = .dismissed
    state.count -= 1
    return .none

  case .incrementButtonTapped:
    state.actionSheet = .dismissed
    state.alert = .dismissed
    state.count += 1
    return .none
  }
}

struct AlertAndSheetView: View {
  let store: Store<AlertAndSheetState, AlertAndSheetAction>

  var body: some View {
    WithViewStore(self.store) { viewStore in
      Form {
        Section(header: Text(template: readMe, .caption)) {
          Text("Count: \(viewStore.count)")

          Button("Alert") { viewStore.send(.alertButtonTapped) }
            .alert(
              self.store.scope(state: { $0.alert }),
              dismiss: .alertCancelTapped
            )

          Button("Action sheet") { viewStore.send(.actionSheetButtonTapped) }
            .actionSheet(
              self.store.scope(state: { $0.actionSheet }),
              dismiss: .actionSheetCancelTapped
            )
        }
      }
    }
    .navigationBarTitle("Alerts & Action Sheets")
  }
}

struct AlertAndSheet_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AlertAndSheetView(
        store: .init(
          initialState: .init(),
          reducer: AlertAndSheetReducer,
          environment: .init()
        )
      )
    }
  }
}