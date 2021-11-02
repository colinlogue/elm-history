# Elm History

This package defines a `History` data structure that can be
used to keep an edit history.

The `History` module exposes a simple API that, similar to
the other `elm-history` packages available, allows keeping
track of a linear progression of states. The
`History.Advanced` module exposes a more general `History`
type with the following differences:

1. The `History` data structure is a tree rather than a
list, allowing multiple futures from any save point. This
allows undoing a change and trying something else without
losing any work.
2. The edit tree has two type parameters: `state` and
`diff`, where `state` is the type of the initial state and
`diff` is a type that can be used to update a state with
an update function of type `diff -> state -> state`.