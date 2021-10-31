module Save exposing (..)

import Advanced.Save as Advanced

type alias Save state = Advanced.Save state state

begin : state -> Save state
begin = Advanced.init always

push : state -> Save state -> Save state
push = Advanced.push

undo : Save state -> Save state
undo = Advanced.undo

redo : Save state -> Save state
redo = Advanced.redo

current : Save state -> state
current = Advanced.current

history : Save state -> List state
history save =
  List.foldl
    (Advanced.getNodeDiff >> (::))
    [ save.initial ]
    save.history