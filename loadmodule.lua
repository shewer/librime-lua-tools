#! /usr/bin/env lua
--
-- loadmodule.lua
-- Copyright (C) 2021 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
-- compnent 
--   load(module , targetname,....)  --  load compnent table to global 
--   --  xxxx.load('english','english1')  english1_processor  english1_filter ....  
--      module  module_name :   lua/module_name.lua  or lua/module_name/init.lua  
--      targetname :    setup conpnent name for (processor , filter , segmentor , translator )
--   unload(targetname)  unload module 
--   --- xxx.unload('english1')  

-- init  lua compnent  to global variable
-- create enter_processor in global
-- create enter_filter in global
-- require( 'main_init')("enter",args)
local compnent={}

-- { targetname= unload_func() , ......} 
compnent.unload_funcs={}

--print( "shared_dir:", rime_api.shared_dir() )
--print( "user_dir:", rime_api.user_dir() )
--print( "sync_dir:", rime_api.sync_dir() )
function compnent.load(module,targetname,...)
--local function init(module, targetname, ...)
--            
	    local _tab= require(module)(...) --  module lua_init(...)  
		-- module must return conpment_tables( processor,filter , translator, segmentor) 
		-- compnent_table ={
		                               
		          
        local unload_keys={}
		--  set compnent_table to  global 
        for key,compnent_tab in pairs( _tab ) do 
                local compnent= targetname .. "_" .. key  --
                log.info("create compnent tabe : " .. tostring( compnent) )
                _G[ compnent ] =   compnent_tab   --  load and v    or  nil
                table.insert(unload_keys, compnent )
        end
		-- insert unload func to table
        compnent.unload_funcs[targetname] = function()
                for i,unload_key in ipairs(unload_keys) do
                        _G[ unload_key] = nil
                end
        end
		return 
end
-- unload  target table  : targetname = english    english_procssor{func=nil,init=nil,fini=nil} english_processor=nil
-- 
function compnent.unload(targetname) 
	local unload_func=  compnent.unload_funcs[targetname] 
	if type(unload_func)== "function"  then 
		unload_func() 
	end 
	compnent.unload_funcs[targetname]=nil
end 
-- unload all  
function compnent.unload_all()
	for k,func in pairs(component.unload_funcs) do
		compnent.unload(k)
	end 
end 

return compnent		  

---
--
--  Component = require( "loadmodule")
--
--
--
--  Compnent.load( "muti_reverse","muti_reverse1" )  -- require( module , 
--
