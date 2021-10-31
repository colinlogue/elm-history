module Save.Test.Random exposing (..)

import Random exposing (Generator)
import Save.Advanced as Save exposing (Save, SaveNode)

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
  }

save : Config state diff -> state -> Generator (Save state diff)
save {update, diffGen} initial =
  let
    applyAction
      : Action
      -> Generator (Save state diff)
      -> Generator (Save state diff)
    applyAction act saveGen =
      case act of
        End ->
          saveGen
        
        Undo ->
          Random.map (Save.undo) saveGen 
        
        Redo ->
          Random.map (Save.redo) saveGen

        Push ->
          saveGen
            |> Random.andThen
              (\save_ ->
                diffGen (Save.current save_)
                  |> Random.map
                    (\diff ->
                      Save.push diff save_))
  in
    actionList
      |> Random.andThen
        (\actions ->
          List.foldl
            applyAction
            (Random.constant <| Save.init update initial)
            actions)