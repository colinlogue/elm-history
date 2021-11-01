module History exposing (..)

import History.Advanced as Advanced

{-| Data structure for keeping 
-}
type alias History state = Advanced.History state state

{-| Start a new edit history from a given initial state.
-}
begin : state -> History state
begin = Advanced.init always

{-| Add a new state to the history. This will create a new future path,
replacing any current future. So if you undo a change and then push a
new change, the undone state will not be recoverable.

  begin 0
    |> push 1
    |> undo
    |> push 2
    |> history
  -- [0,2]  

-}
push : state -> History state -> History state
push = Advanced.push

{-| Move back one 
-}
undo : History state -> History state
undo = Advanced.undo

redo : History state -> History state
redo = Advanced.redo

current : History state -> state
current = Advanced.current

history : History state -> List state
history save =
  List.foldl
    (Advanced.getNodeDiff >> (::))
    [ save.initial ]
    save.history

