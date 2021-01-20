#! /usr/bin/env lua
--
-- notifier.lua
-- Copyright (C) 2021 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
-- for librime-lua  notifier 
--


require 'tools/object'


Notifier=Class("Notifier")

function Notifier:_initialize(env)
	self._env=env
	self._ctx=env.engine.context
	self.list=metatable()
	return self

end
function Notifier:_connect(name,func)
	local connection= self._cix[name]:connect(func)
	self._list:insert(connection)
	return  connection
end 
	
function Notifier:disconnect()
	for i,connection in next , self._list do
		connection:disconnect()
	    self._list[i] = nil
	end
end

function Notifier:commit(func) -- func(ctx) 
	return self:_connect("commit_notifier",func)
end 
function Notifier:select(func) -- func(ctx) 
	return self:_connect("select_notifier",func)
end
function Notifier:update(func) -- func(ctx) 
	return self:_connect("update_notifier",func)
end
function Notifier:delete(func) -- func(ctx) 
	return self:_connect("delete_notifier",func)
end
function Notifier:option(func) -- func(ctx,name) 
	return self:_connect("option_update_notifier",func)
end
function Notifier:property(func) -- func(ctx,name) 
	return self:_connect("property_update_notifier",func)
end
function Notifier:unhandled_key(func) -- func(ctx) 
	return self:_connect("unhandled_key_notifier",func)
end
		

return Notifier
















