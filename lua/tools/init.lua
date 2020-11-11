#! /usr/bin/env lua
--
-- init.lua
-- Copyright (C) 2020 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
require('tools/metatable')
local log=require( 'tools/log')(log)
local debug=require( 'tools/debug')
local schema_func=require("tools/schema_func")




return {log=log,debug=debug,schema_func}



