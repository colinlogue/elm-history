module History.Advanced exposing (..)

type alias SaveId = Int

type SavePoint diff
  = SaveNode
    { id : SaveId
    , diff : diff
    , futures : (List (SavePoint diff))
    }

getSaveDiff : SavePoint diff -> diff
getSaveDiff (SaveNode {diff})= diff

getSaveId : SavePoint diff -> SaveId
getSaveId (SaveNode {id}) = id

getSaveFutures : SavePoint diff -> List (SavePoint diff)
getSaveFutures (SaveNode{futures}) = futures

type alias History state diff =
  { initial : state
  , history : List (SavePoint diff)
  , futures : List (SavePoint diff)
  , update : diff -> state -> state
  , nextId : SaveId
  , maxBranching : Maybe Int
  }

init
  : (diff -> state -> state)
  -> Maybe Int
  -> state
  -> History state diff
init update maxBranch initial =
  { initial = initial
  , history = []
  , futures = []
  , update = update
  , nextId = 0
  , maxBranching = maxBranch
  }

current : History state diff -> state
current save =
  List.foldr
    (getSaveDiff >> save.update)
    save.initial
    save.history

undo : History state diff -> History state diff
undo save =
  case save.history of
    [] ->
      save
    
    SaveNode {id, diff, futures} :: history ->
      { save
          | history = history
          , futures =
            SaveNode
              { id = id
              , diff = diff
              , futures = save.futures
              } :: futures
      }

undoAll : History state diff -> History state diff
undoAll save =
  case save.history of
    [] ->
      save

    _ ->
      undoAll (undo save)

redo : History state diff -> History state diff
redo save =
  case save.futures of
    [] ->
      save
    
    SaveNode {id, diff, futures} :: alternatives ->
      { save
          | futures = futures
          , history =
            SaveNode
            { id = id
            , diff = diff
            , futures = alternatives
            } :: save.history
      }

redoAll : History state diff -> History state diff
redoAll save =
  case save.futures of
    [] ->
      save
    
    _ ->
      redoAll (redo save)

push : diff -> History state diff -> History state diff
push diff save =
  let
    futures : List (SavePoint diff)
    futures =
      case save.maxBranching of
        Just limit ->
          List.take limit save.futures
        
        Nothing ->
          save.futures
  in
  { save
      | history =
        SaveNode
          { id = save.nextId
          , diff = diff
          , futures = futures
          } :: save.history
      , futures = []
      , nextId = save.nextId + 1
  }

{-| Arrange the list of futures by some List function. The arranging
function should take a list and return a permutation of that list, so
the same elements remain in the list but they may be in a different
order.
-}
arrangeFutures
  : (List (SavePoint diff) -> List (SavePoint diff))
  -> History state diff
  -> History state diff
arrangeFutures arrange save =
  { save | futures = arrange save.futures }

{-| Moves the top future path to the back of the list.
-}
cycleFutures : History state diff -> History state diff
cycleFutures save =
  case save.futures of
    [] ->
      save

    future :: futures ->
      { save
          | futures = futures ++ [ future ]
      }