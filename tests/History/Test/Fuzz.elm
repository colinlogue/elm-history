module History.Test.Fuzz exposing (..)

import Fuzz exposing (Fuzzer)
import History.Advanced exposing (..)
import History.Test.Random as Random
import Random exposing (Generator)
import Shrink



type alias Config state diff =
  { update : diff -> state -> state
  , diffGen : state -> Generator diff
  }

save : Config state diff -> state -> Fuzzer (History state diff)
save config initial =
  Fuzz.custom
    (Random.save config initial)
    Shrink.noShrink