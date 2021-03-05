#! /usr/bin/env lua
--
-- main_init.lua
-- Copyright (C) 2020 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
--------------------------------------------

--  lua_init(argv) argv 自定義
local Notifier=require ('tools/notifier') -- 建立 notifier obj   減化 notifier connect and disconnect() 
-- 取得 librime 狀態 tab { always=true ....}
local function status(ctx)
    local stat=metatable()
    local comp= ctx.composition
    stat.always=true
    stat.composing= ctx:is_composing()
    stat.empty= not stat.composing
    stat.has_menu= ctx:has_menu()
    stat.paging= not comp:empty() and comp:back():has_tag("paging")
    return stat
end
local function lua_init(...)
	local args={...} 

	local function processor_func(key,env) -- key:KeyEvent,env_
		local Rejected, Accepted, Noop = 0,1,2 
		local engine=env.engine
		local context=engine.context
		local s= status(context) 


		if s.empty then end 
		if s.always then end 
		if s.has_menu then end 
		if s.composing then end 
		if s.paging then end 


		return Noop  
	end 

	local function processor_init_func(env)
		env.connect=Notifier(env) -- 提供 7種notifier commit update select delete option_update property_update unhandle_key
		--env.connect:commit( func)
		--env.connect:update( func)

	end 

	local function processor_fini_func(env) 
		env.connect:disconnect() -- 將所有 connection  disconnect() 
	end 

	-- segmentor 
	local function segmentor_func(segs ,env) -- segmetation:Segmentation,env_


	-- 終止 後面 segmentor   打tag  
	-- return  true next segmentor check
		return true 
	end 
	local function segmentor_init_func(env)
	end 
	local function segmentor_fini_func(env)
	end 

	-- translator 
	local function translator_func(input,seg,env)  -- input:string, seg:Segment, env_

		-- yield( Candidate( type , seg.start,seg._end, data , comment )
	end 
	local function translator_init_func(env)
	end 
	local function translator_fini_func(env)
	end 

	--- filter  
	local function filter_func(input,seg,env)   -- pass filter 
		for cand in input:iter() do 
			yield(cand)
		end 
	end 
	local function filter_init_func(env)
	end 
	local function filter_fini_func(env)
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





return lua_init    
