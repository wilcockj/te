---@meta
---@diagnostic disable: unused-local, lowercase-global

-- Color enum
---@alias Color integer
BLACK = 0; BLUE = 1; GREEN = 2; CYAN = 3; RED = 4
MAGENTA = 5; BROWN = 6; LIGHT_GRAY = 7; DARK_GRAY = 8
LIGHT_BLUE = 9; LIGHT_GREEN = 10; LIGHT_CYAN = 11
LIGHT_RED = 12; LIGHT_MAGENTA = 13; YELLOW = 14; WHITE = 15

-- Key enum
---@alias Key
---| '"a"'|'"b"'|'"c"'|'"d"'|'"e"'|'"f"'|'"g"'
---| '"h"'|'"i"'|'"j"'|'"k"'|'"l"'|'"m"'|'"n"'
---| '"o"'|'"p"'|'"q"'|'"r"'|'"s"'|'"t"'
---| '"u"'|'"v"'|'"w"'|'"x"'|'"y"'|'"z"'
---| '"0"'|'"1"'|'"2"'|'"3"'|'"4"'|'"5"'|'"6"'|'"7"'|'"8"'|'"9"'
---| '"space"'|'"enter"'|'"escape"'|'"tab"'|'"backspace"'
---| '"left"'|'"right"'|'"up"'|'"down"'
---| '"f1"'|'"f2"'|'"f3"'|'"f4"'|'"f5"'|'"f6"'|'"f7"'|'"f8"'|'"f9"'|'"f10"'|'"f11"'|'"f12"'

-- Engine objects
---@class te_window
---@field getDimensions fun():integer, integer
---@field getFPS fun():integer

---@class te_graphics
---@field clear fun():nil
---@field setColor fun(fg:Color, bg:Color):nil
---@field setCell fun(glyph:integer, x:integer, y:integer):nil
---@field print fun(text:string, x:integer, y:integer):nil

---@class te_event
---@field quit fun(exitCode:integer):nil

-- Root te table
---@class te
---@field window te_window
---@field graphics te_graphics
---@field event te_event
-- Lifecycle hooks as fields instead of functions
---@field load fun():nil
---@field update fun(dt:number):nil
---@field draw fun():nil
---@field keypressed fun(key:Key):nil
te = {}
