Description
===========
This implements a small subset of Ratpoison commands in Hammerspoon.

The main ones are:

select [0-9]: select windows with 0-9
other [prefix]: select the last window again
number [n 0-9]: bind a window to a number
meta/literal: sends a literal prefix

Configuration
=============
Set your desired prefix key in the `prefix` table. Change bindings by searching for lines containing `bind`.

Todo
====
- Automatic window layout like in Ratpoison?
