
Integrate into Alfred.
Or create StopLight search?


# Pipeline design

A plug-in returns the commands it wishes to execute.

When there are commands returned, by default these are simulated after each step.

A Command is UpdateIndex, which takes an index it can mutate.
Retention of old versions, if needed, is a responsibility of the caller.

The '+' sign before a plug-in means that commands are processed, not the index.
If just the plug-in name, it's as a `Index -> [Cmd]` function.

Processing of commands allows for retention via `:keep` return value.
Otherwise `nil` must be returned and the command is removed.

It is not an error to stop with a non-empty pipeline.

Symbols `+`, `?`,  can be part of the name. 

Parse command line parameters myself.
Concat `ARGV` and parse.

First plug-in always establishes the first Index.
It receives a stream (stdin).

Index must become an abstract superclass.





The first 


    dx @tag+find with-tags:Green, Blue clean-downloads +bash sort-downloads +bash

    dx tag+find create-db: ~/.dx/dl-index
    


    findp name:"Codi Vore"

    #!/usr/bin/env sh
    dx db:~/.dx/dl-index select:$ $* \; dump
