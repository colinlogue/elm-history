module SaveTests exposing (..)

import Expect
import History.Test.Fuzz
import List.Extra as List
import Random
import History.Advanced as History exposing (History, SavePoint, SaveId)
import History.Test.Fuzz as Fuzz
import Test exposing (..)


allIds : History state diff -> List SaveId
allIds {history, futures} =
  List.foldr (History.getSaveId >> (::)) [] (history ++ futures)

config : Fuzz.Config String String
config =
  { update = (++)
  , diffGen =
    always
      <| Random.uniform ("a")
        [ "b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"
        , "q","r","s","t","u","v","w","x","y","z" ]
  , maxBranch = Nothing
  }

suite : Test
suite =
  describe "Save.Advanced tests"
    [ test "init produces no history" <|
      \_ ->
        Expect.equal
          (History.init always Nothing 0).history
          []
    , test "init produces no futures" <|
      \_ ->
        Expect.equal
          (History.init always Nothing 0).futures
          []
    , fuzz (Fuzz.save config "") "nextId is unique after push" <|
      \save ->
        Expect.equal
          (List.length <| allIds save)
          (List.length <| List.unique <| allIds save)
    , fuzz (Fuzz.save config "") "undo >> redo >> undo = undo" <|
      \save ->
        Expect.equal
          (History.current <| History.undo <| History.redo <| History.undo save)
          (History.current <| History.undo save)
    , fuzz (Fuzz.save config "") "redo >> undo >> redo = redo" <|
      \save ->
        Expect.equal
          (History.current <| History.redo <| History.undo <| History.redo save)
          (History.current <| History.redo save)
    ]