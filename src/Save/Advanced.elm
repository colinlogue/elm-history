module Save.Advanced exposing (..)

type alias NodeId = Int

type SaveNode diff
  = SaveNode
    { id : NodeId
    , diff : diff
    , futures : (List (SaveNode diff))
    }

getNodeDiff : SaveNode diff -> diff
getNodeDiff (SaveNode {diff})= diff

getNodeId : SaveNode diff -> NodeId
getNodeId (SaveNode {id}) = id

getNodeFutures : SaveNode diff -> List (SaveNode diff)
getNodeFutures (SaveNode{futures}) = futures

type alias Save state diff =
  { initial : state
  , history : List (SaveNode diff)
  , futures : List (SaveNode diff)
  , update : diff -> state -> state
  , nextId : NodeId
  }

init : (diff -> state -> state) -> state -> Save state diff
init update initial =
  { initial = initial
  , history = []
  , futures = []
  , update = update
  , nextId = 0
  }

current : Save state diff -> state
current save =
  List.foldr
    (getNodeDiff >> save.update)
    save.initial
    save.history

undo : Save state diff -> Save state diff
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

redo : Save state diff -> Save state diff
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

push : diff -> Save state diff -> Save state diff
push diff save =
  { save
      | history =
        SaveNode
          { id = save.nextId
          , diff = diff
          , futures = save.futures
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
  : (List (SaveNode diff) -> List (SaveNode diff))
  -> Save state diff
  -> Save state diff
arrangeFutures arrange save =
  { save | futures = arrange save.futures }

{-| Moves the top future path to the back of the list.
-}
cycleFutures : Save state diff -> Save state diff
cycleFutures save =
  case save.futures of
    [] ->
      save

    future :: futures ->
      { save
          | futures = futures ++ [ future ]
      }