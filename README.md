# Elm History

This package defines a `History` data structure that can be
used to keep an edit history.

There is a simple version in the `History` module that keeps
a linear history of states.

The `History.Advanced` module defines a `History`
parameterized by a `state` type for the initial state and a
`diff` type that describes changes to a state. This model
also allows branching paths, so when you undo and push a new
change, a new branch is created but the previous redo path
is saved.