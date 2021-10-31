module SaveTests exposing (..)

import Expect
import Fuzz
import List.Extra as List
import Random
import Save.Advanced as Save exposing (Save, SaveNode, NodeId)
import Save.Test.Fuzz as Fuzz
import Test exposing (..)


allIds : Save state diff -> List NodeId
allIds {history, futures} =
  List.foldr (Save.getNodeId >> (::)) [] (history ++ futures)

config : Fuzz.Config String String
config =
  { update = (++)
  , diffGen =
    always
      <| Random.uniform ("a")
        [ "b","c","d","e","f","g","h","i","j","k","l","m","n","o","p"
        , "q","r","s","t","u","v","w","x","y","z" ]
  }

suite : Test
suite =
  describe "Save.Advanced tests"
    [ test "init produces no history" <|
      \_ ->
        Expect.equal
          (Save.init always 0).history
          []
    , test "init produces no futures" <|
      \_ ->
        Expect.equal
          (Save.init always 0).futures
          []
    , fuzz (Fuzz.save config "") "nextId is unique after push" <|
      \save ->
        Expect.equal
          (List.length <| allIds save)
          (List.length <| List.unique <| allIds save)
    , fuzz (Fuzz.save config "") "undo >> redo >> undo = undo" <|
      \save ->
        Expect.equal
          (Save.current <| Save.undo <| Save.redo <| Save.undo save)
          (Save.current <| Save.undo save)
    , fuzz (Fuzz.save config "") "redo >> undo >> redo = redo" <|
      \save ->
        Expect.equal
          (Save.current <| Save.redo <| Save.undo <| Save.redo save)
          (Save.current <| Save.redo save)
    ]