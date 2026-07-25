import ComposableArchitecture

@Reducer
struct Feature {
    @ObservableState
    struct State {
        @Presents var destination: Destination.State?
    }
    enum Action {
        case destination(PresentationAction<Destination.Action>)
    }
    
    @Reducer
    enum Destination {
        case alert(AlertState<Never>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in .none }
        .ifLet(\.$destination, action: \.destination)
    }
}
