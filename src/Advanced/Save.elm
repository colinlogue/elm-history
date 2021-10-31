module Advanced.Save exposing (..)


type SaveNode diff
  = SaveNode diff (List (SaveNode diff))

type alias Save state diff =
  { initial : state
  , history : List (SaveNode diff)
  , futures : List (SaveNode diff)
  , update : diff -> state -> state
  }

current : Save state diff -> state
current save =
  let
    getDiff : SaveNode diff -> diff
    getDiff (SaveNode diff _) = diff
  in
    List.foldr
      (getDiff >> save.update)
      save.initial
      save.history

undo : Save state diff -> Save state diff
undo save =
  case save.history of
    [] ->
      save
    
    SaveNode prev alternates :: history ->
      { save
          | history = history
          , futures = SaveNode prev save.futures :: alternates
      }

redo : Save state diff -> Save state diff
redo save =
  case save.futures of
    [] ->
      save
    
    SaveNode next futures :: alternatives ->
      { save
          | futures = futures
          , history = SaveNode next alternatives :: save.history
      }

push : diff -> Save state diff -> Save state diff
push diff save =
  { save
      | history = SaveNode diff save.futures :: save.history
      , futures = []
  }


arrangeFutures
  : (List (SaveNode diff) -> List (SaveNode diff))
  -> Save state diff
  -> Save state diff
arrangeFutures arrange save =
  { save | futures = arrange save.futures }

cycleFutures : Save state diff -> Save state diff
cycleFutures save =
  case save.futures of
    [] ->
      save

    future :: futures ->
      { save
          | futures = futures ++ [ future ]
      }

