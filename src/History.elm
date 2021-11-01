module History exposing (..)

import History.Advanced as Advanced

{-| Data structure for keeping a linear edit history.
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

{-| Move back one step in the history. Undoing from the initial state
returns the history unchanged.

  begin 0
    |> push 1
    |> push 2
    |> undo
    |> history
  -- [0,1]

  undo (begin 0) == begin 0
  -- True

-}
undo : History state -> History state
undo = Advanced.undo

{-| Move forward one step in the history. Redoing from a state with no
future path returns the history unchanged.

  begin 0
    |> push 1
    |> undo
    |> redo
    |> history
  -- [0,1]

  begin 0
    |> push 1
    |> push 2
    |> redo
    |> history
  -- [0,1,2]

-}
redo : History state -> History state
redo = Advanced.redo

{-| Get the current state in the history.

  begin 0
    |> current
  -- 0

  begin 0
    |> push 1
    |> push 2
    |> undo
    |> current
  -- 1

-}
current : History state -> state
current = Advanced.current

{-| Get the history up to and including the current state as a list.
-}
history : History state -> List state
history save =
  List.foldl
    (Advanced.getNodeDiff >> (::))
    [ save.initial ]
    save.history

