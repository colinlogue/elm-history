module Save.Test.Fuzz exposing (..)

import Fuzz exposing (Fuzzer)
import Random exposing (Generator)
import Save.Advanced exposing (..)
import Save.Test.Random as Random
import Shrink



type alias Config state diff =
  { update : diff -> state -> state
  , diffGen : state -> Generator diff
  }

save : Config state diff -> state -> Fuzzer (Save state diff)
save config initial =
  Fuzz.custom
    (Random.save config initial)
    Shrink.noShrink