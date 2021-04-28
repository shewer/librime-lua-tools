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
  return func
end
function Notifier:remove(func)
  local _,index=self._list:find(func)
  self._list:remove(index)
  return  index and self._list:remove(index) 
end 
function Notifier:funcs()
  return self._list
end 
function Notifier:callback(...)
  self._mainfunc(...)
end 



local Notifiers=Class("Notifiers")

function Notifiers:_initialize(ctx)
    self._key= metatable({"commit","select","update","option","property","unhandled" }) 
    if ctx then 
      self:setup(ctx)
    end 
    return self
end
function Notifiers:setup(ctx)
    self.commit=Notifier(    ctx.commit_notifier         )
    self.select=Notifier(    ctx.select_notifier         )
    self.update=Notifier(    ctx.update_notifier         )
    self.option=Notifier(    ctx.option_update_notifier  )
    self.property=Notifier(  ctx.property_update_notifier)
    self.unhandled=Notifier( ctx.unhandled_key_notifier  ) 
end 
function Notifiers:reset()
  self._key:each( function(elm) 
     self[elm]:reset()
     self[elm]=nil
   end )

end 

function Notifiers:connect()
  self._key:each( function(elm) 
     self[elm]:connect()
   end )
end 
function Notifiers:disconnect()
  self._key:each( function(elm) 
     self[elmr]:disconnect()
   end )
end 

return Notifiers

