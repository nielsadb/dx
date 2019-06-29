
# TODO

* Create proper state class, with basic methods for adding roots etc.
  - factors out state-building from only plug-in I have now

* Create a hierarchy of commands under Cmd.
  - each with own initializer
  - super constructor accepts tag and other generic stuff

# Design stuff

Due to dynamic typing you really cannot use the open data structures.
You are more likely to need classes so you can easily refacor.

A command transformer (CmdT) is a Cmd * Stream -> () function. Registered by plug-ins.

Create an actual design. Put different design parts in Modules.

Put modules into separate files.
Dismissed idea: use instance_eval on a plug-in placeholder containing the state.
Why dismissed: I don't want to create an open state class.
Probably the methods in instance_eval can access private data.
