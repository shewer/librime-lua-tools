#! /usr/bin/env lua
--
-- main_init.lua
-- Copyright (C) 2020 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
--------------------------------------------
-- 在 processors  載入第一個  利用  processor_init_func  載入 lua_env/load_module  全域 
-- 在 filter      載入最後一個 利用 filter_fini_func 移除 己載入 全域 module 
-- main_init.yaml
--   patch: 
--   	engine/processors/@before 0: lua_processor@enter_processor
--   	negine/filters/@next: lua_filter@enter_filter
--  
-- rime.lua
-- require("main_init")("enter") 
--
-- 使用範例 -- 導入 應用模組
-- reverse_switch.yaml 
--  patch:
--     engine/processors/@after 0: lua_processor@mtest_processor
--     #   require("muti_reverse")("muti_reverse","preedit_fmt")  args1 lua component
--     engine/filters/@after 1: lua_filter@test_filter 
--     #  等同在  rime.lua  載入
--
--     lua_env/load_modules:+
--     	- { module:  "muti_reverse" ,args: [ "test","preedit_fmt" ] }   
--
--     #  配合 reverse_switch  需要 在 rime.lua 載入的模組， 由enter_processor init 時載入
--     #  讀取 schema: lua_env/load_modules: 將 reverse_switch 所需 func 導入至 全域 _G[ ] 
--     lua_env/load_modules:   
--        - { module: muti_reverse , args: [ muti_reverse, preedit_fmt ] }
--
-- cangjie5.custom.yaml
--
-- patch:
--
--     __include: main_init:/patch   
--     __include: reverse_switch:/patch  # 導入 lua component 
--

--------------------------------------------
-- 模組 需求 
-- require( 'test') (name, args )  return unload_func() 
-- 在 lua/test.lua or lua/test/init.lua
--    local tab = { 
--          processor= { func = processor_func, init= processor_init_func, fini= processor_fini } , 
--          segment= { ..},
--          translator = { ...} ,
--          filter = { ...},
--    }
--  
--local   function init(name, ... )
--     local unload_keys={}
--     for key,v in pairs(tab) do 
--         _G[ name .. "_" .. k] = v 
--         table.insert(unload_keys ,   name .. "_" .. key )
--
--     end 
--     return _function()  -- return unload func 
--         for i,unload_key  in ipairs( unload_keys ) do 
--             _G[ key ] = nil 
--         end 
--     end 
--
--
--

--------------------------------------------
-- load module call  require( module_name )( args )  
-- -- set module_function to _G  
-- example:
--   local unload_func = requrie( "muti_reverse" )( "muti", "comment_fmt" )  -- set _G[muti_processor] ,_G[muti_filter] 
--   return unload() func
--
--    
--
-- load from schmea.yaml   
-- lua_env/load_modules:
--    - { modules: "require modules name" , args: [ .....] 
--    - .....
--
-- 	
local function load_list_string(config, key)
	local list ={}
	local end_index = config:get_list_size( key) -1
	for i=0,end_index do 
		table.insert( list , 
		config:get_string( key .. "/@" .. i ) -- key/@i 
		)
	end 
	return list 
end 

local function load_modules_data_form_yaml(config)
		local modules=setmetatable({},{__index=table} )
		local schema_func= require('tools/schema_func')
		local modules_name= "lua_env/load_modules"
		local module_name= "module"
		local module_args="args"
		-- create  mudules list : [ {module: "require_module_name ", args: [ args_list of string] 
		local modules_size =config:get_list_size(modules_name) 
		for i=0,(modules_size-1)  do 
			local key_tmp= modules_name .."/@" .. i .. "/"
			local module = config:get_string( key_tmp  .. module_name , "string")
			local module_args= load_list_string( config , key_tmp .. module_args)
			modules:insert({module=module,args=module_args} )
			log.info( 
				("lua_env/load_module data: {module:\"%s\" , args: [ %s ]} "):format(
				 module, table.concat(module_args, ",")  )  
			)
		end 
		return modules
end 
-- reterun unload()  func 
local function load_modules(modules_data)
	local unload_funcs={}
	for i,md in ipairs(modules_data) do 
		table.insert( unload_funcs, 
			require( md.module)( table.unpack(md.args)  ) 
			)
		log.info( 
			(" requrie module  frome modules_data :   require( \"%s\")(   %s  ) "):format(
			 md.module, table.concat(md.args, ",")  )  
		)
	end 
	-- return unload() func 
	return function() 
		for i,unload_func in ipairs( unload_funcs ) do 
			log.info("-- execute  unload func: " .. type(unload_func) ) 
			unload_func()
		end 
	end 
end 



local function lua_init()
	local unloads_func 
	local function processor_func(key,env) -- key:KeyEvent,env_
		return 2  -- always pass 
	end 

	local function processor_init_func(env)
		-- load module from schema: lua_env/load_modules  and link env._unload_funcs() 
		-- lua_env:
		--    - { module: module , args: [ args of list ] } 
		local modules_data= load_modules_data_form_yaml(env.engine.schema.config) 
		--  return unload func 
		unloads_func = load_modules( modules_data)
	end 

	local function processor_fini_func(env) 
	end 



	--- filter  
	local function filter_func(input,seg,env)   -- pass filter 
		for cand in input:iter() do 
			yield(cand)
		end 
	end 
	local function filter_init_func(env)
		env._unloads=unloads_func
		log.info("--filter_init------ check _unload_func: " .. type(unloads_func) .."/" .. type(env._unloads)  )
	end 
	local function filter_fini_func(env)
		log.info("--filter_fini------ check _unload_func: " .. type(unloads_func) .."/" .. type(env._unloads)  )
		env._unloads()
	end 

	local _tab= { 
		processor= { func=processor_func, init=processor_init_func, fini=processor_fini_func} , 
		--segmentor= { func= segmentor_func, init=segmentor_init_func , fini=segmentor_fini_func} , 
		--translator={ func=translator_func, init=translator_init_func,fini=translator_fini_func} , 
		filter=    { func=filter_func, init=filter_init_func,    fini=filter_fini_func } ,   
		--filter1=    { func=filter_func1, init=filter_init_func1,    fini=filter_fini_func1 } ,   
	}
	return _tab
end 
-- create global  function  to   lua_component 
-- 



-- init  lua component  to global variable
-- create enter_processor in global
-- create enter_filter in global 
-- require( 'main_init')("enter") 
local function init(tagname)
	local _tab= lua_init() 
	local unload_keys={}
	for key,component_tab in pairs( _tab ) do 
		local component= tagname .. "_" .. key  --  
		_G[ component ] =   component_tab   --  load and v    or  nil 
		table.insert(unload_keys, component )
	end 
	return function()
		for i,unload_key in ipairs(unload_keys) do
			_G[ unload_key] = nil 
		end 
	end 
end 


return init    
