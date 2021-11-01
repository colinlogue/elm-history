module History.Test.Random exposing (..)

import Random exposing (Generator)
import History.Advanced as History exposing (History, SavePoint)

type Action
  = Push
  | Undo
  | Redo
  | End

action : diff -> Generator Action
action diff =
  Random.uniform
    End
    [ Undo
    , Redo
    , Push
    ]

actionList : Generator (List Action)
actionList =
  Random.uniform Push [ Undo, Redo, End ]
    |> Random.andThen
      (\act ->
        case act of
          End ->
            Random.constant [ End ]
          
          _ ->
            Random.map ((::) act) actionList
        )

type alias Config state diff =
  { update : diff -> state -> state
  , diffGen : state -> Generator diff
  , maxBranch : Maybe Int
  }

save : Config state diff -> state -> Generator (History state diff)
save {update, diffGen, maxBranch} initial =
  let
    applyAction
      : Action
      -> Generator (History state diff)
      -> Generator (History state diff)
    applyAction act saveGen =
      case act of
        End ->
          saveGen
        
        Undo ->
          Random.map (History.undo) saveGen 
        
        Redo ->
          Random.map (History.redo) saveGen

        Push ->
          saveGen
            |> Random.andThen
              (\save_ ->
                diffGen (History.current save_)
                  |> Random.map
                    (\diff ->
                      History.push diff save_))
  in
    actionList
      |> Random.andThen
        (\actions ->
          List.foldl
            applyAction
            (Random.constant <| History.init update maxBranch initial)
            actions)