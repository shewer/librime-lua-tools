#! /usr/bin/env lua
--
-- anotifier.lua
-- Copyright (C) 2021 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--

require('tools/metatable')
require("tools/object")
local Notifier=Class("Notifier")

function Notifier:_initialize(notifier)
  self:setup(notifier)
  return self
end


function Notifier:setup(notifier)
  self:reset()
  self._list=metatable()
  self._mainfunc=self:_gener_mainfunc(self._list)
  self:connect(notifier)
end


function Notifier:_gener_mainfunc(list)
  return function(...)
    for _,ffunc in ipairs(list) do
      if type(ffunc) == "function" and ffunc(...) then
        break
      end
    end
  end
end

function Notifier:disconnect()
  if self._connection  then
    self._connection:disconnect()
    self._connection=nil
  end
end
function Notifier:connect(notifier)
  self:disconnect()
  self._connection= self._mainfunc and notifier:connect( self._mainfunc ) or nil
end

function Notifier:reset()
  self:disconnect()
  self._list=nil
end
function Notifier:append(func)
  self._list:insert(func)
end
function Notifier:remove(func)
  return  self._list:delete(func) --index and self._list:remove(index)
end
function Notifier:funcs()
  return self._list
end
function Notifier:callback(...)
  self._mainfunc(...)
end

local notifier_name= {
  commit = "commit_notifier",
  select = "select_notifier",
  update = "update_notifier",
  delete = "delete_notifier",
  option = "option_update_notifier",
  property = "property_update_notifier",
  unhandled = "unhandled_key_notifier",
}


local Notifiers=Class("Notifiers")

function Notifiers:_initialize(ctx)
    if ctx then
      self:setup(ctx)
    end
    return self
end
function Notifiers:setup(ctx)
  for k,v in pairs(notifier_name) do
    self[k] = Notifier( ctx[v] )
  end
  if log then
     log.error( "------ delete notifier " .. tostring(ctx) .. "---" .. tostring(self.delete))
  end
end
function Notifiers:reset()
  for k,v in pairs(notifier_name) do
    self[k]:reset()
    self[k]=nil
  end
end

function Notifiers:connect()
  for k,v in pairs(notifier_name) do
    self[k]:connect()
  end
end
function Notifiers:disconnect()
  for k,v in pairs(notifier_name) do
    self[k]:disconnect()
  end
end

return Notifiers

