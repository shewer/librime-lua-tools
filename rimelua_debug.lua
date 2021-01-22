#! /usr/bin/env lua
--
-- debug.lua
-- Copyright (C) 2020 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
require 'muti_reverse.metatable'
local function objlist(obj,elm,seg, ... )	
	local  _type= type(obj) 
	if _type == "string" then 
		yield(Candidate("debug",seg.start,seg._end, obj  ,_type ) ) 
	elseif _type == "number" then 
		yield(Candidate("debug",seg.start,seg._end, obj ,_type) )
	elseif _type == "function" then 
		yield(Candidate("debug",seg.start,seg._end, tostring(obj) ,_type) )
		--local ptab={ pcall(obj, ... ) }
		--for i,v in ipairs(ptab) do 
		--yield(Candidate("debug",seg.start,seg._end, string.format("%s : %s",i,v) ,"table"))
		--end
	elseif _type == "table" or _obj:is_a(Object) then 

		for k,v in pairs(obj) do 
			if elm=="" or k:match("^" .. elm) then 
				yield(Candidate("debug",seg.start,seg._end, string.format("%s : %s",k,v) ,_type))
			end 
		end 
	end 
end 
--   
local function match_sort(tab,str)
	--local tmp=metatable()
	print("str  " , str)
	--for k,v in pairs(tab) do print(k,v) end 
	--metatable(tab) 

	local tmp=   table.map_hash(tab )
	--for _,elm in ipairs(tmp) do print("-----" , elm[1],elm[2] ) end 
	tmp:sort(function(v1,v2) return v1[1]< v2[1] end ) --tab to list { {k,v},{k,v}....} 
	print( "str s " .. tostring(tmp) ) 
	local tmp2= metatable()
	for _,elm in ipairs(tmp) do
		
		if  tostring(elm[1]):match("^" .. str) then
			tmp2:insert(1,elm) -- insert form head
		else
			tmp2:insert(elm)  -- insert from tail
		end
	end 
	--print("------------------------return")
	--tmp2:each(function(elm)  print(elm[1],elm[2]) end ) 
	--print("------------------------return")
	return tmp2
end

local function tab_conv(str,reg) -- ok     
	local V = reg or _G
	local indexw=""
	local Vtmp
	for w in str:gmatch( "[%w_]*") do 
		Vtmp = V[tonumber(w) or w ]
		local _type=type(Vtmp)
		if _type == "nil" or  _type ~= "table" then  break end 
		V=Vtmp
	end 
	return Vtmp
end 


local function type_conv(str) --- ok 
	local tmp= tonumber(str)
	if tmp then return tmp end 
	tmp= str:match("[\'\"](.*)[\'\"]")
	if tmp then return tmp end 
	tmp= tab_conv(str) 
	return tmp


end 
local function argv_conv(str) -- ok  
	str= str or ""  -- nil  or ""  empty 
	local tab=metatable() 
	--for w in str:gmatch("[%w._\"]*") do  
	for w in str:gmatch("[^,]*") do  --  "%s -- %s "   for string.format() 
		tab:insert( type_conv(w) )
	end 
	return tab:unpack()
end 

local function conv(str)
  --  split   var   and argv
  local V=_G
  local v= str:match("([%a_][%w_+.]*)%(.*%)?") -- a3234.oeoeu.oeuoeu.oeuoeu( argv) 
  local arg= str:match("[%a_][%w+_]*(%(.*%))")
  return  type_conv(v) , argv_conv(arg)

end 
local function exec(func, ...)
   if type(func) == "function" then 
	   return func(...)
   end 
end 



















-- return match data of list 
local function rime_lua_debug(_input,seg,env)
	--yield(Candidate("debug", seg.start, seg._end,_input , "dubug:"))
	local index=1
	local _L =metatable()
	while true do
	    local name,value=debug.getlocal(2,index)
		if not name then break end 
		_L[name]=value
		index=index +1
	end 
	
	--env.preedit= init_data(env) 
	local tab= metatable() -- init list 
	local t , input = _input:match("^([GLF])(.*)$" ) -- splite Goble|Local  string
	if not t then return end  -- not match 
	local _tabb = input:split("(") -- split  tab , argv
	local obj_str, argv_str = table.unpack( input:split("(") )

	local inp_tab = ( argv_str and argv_str:split(",") ) or {} 
	local V=  (t =="L" and _L) or _G	
	local lev = 0
	local usesdata
	local match_obj=nil
	for  obj in  obj_str:gmatch("[%w_+]*") do 
		lev=lev+1
		print( "----------lev:  ",lev , V,obj)
		if type(V) == "userdata" then 
			-- bypass  match_sort 目前無法處理 userdata
			
		else 
			tab=match_sort(V,obj) -- 預排清單
		end 
		match_obj=V[tonumber(obj) or obj ] ---   numberstr to string or key string 
		if match_obj then 
			local _type = type(match_obj)
			if _type == "number" then 
				tab:insert(1,{match_obj,_type}) -- 插仆 數值
			elseif _type == "boolean" then
				print("---------match string--------")
				tab:insert(1,{match_obj,_type }) -- 插入 字串值
			elseif _type == "string" then
				print("---------match string--------")
				tab:insert(1,{match_obj,_type }) -- 插入 字串值
			elseif _type == "function" then 
				print("---------match string--------")
			elseif _type== "table"   then 
				V= match_obj   --  V  變更下一層  如果 還有 子字串
			elseif match_obj.is_a and match_obj:is_a(Object)   then 
				V= match_obj   --  V  變更下一層  如果 還有 子字串
			elseif _type == "userdata" then
				userdata= match_obj -- 試著 如果 userdata data_get  userdata 會有值       
				if type(userdata)== "number" then 
					tab:insert(1,{userdata,_type }) -- 插入 字串值
				elseif type(userdata) == "boolean" then
					tab:insert(1,{userdata,_type }) -- 插入 字串值
				elseif type(userdata) == "string" then
					tab:insert(1,{userdata,_type}) -- 插仆 數值
				elseif type(userdata)== "function" then 
					tab:insert(1,{userdata,_type}) -- 插仆 數值
				elseif type(userdata)== "userdata" then 
					tab:insert(1,{match_obj,userdata or _type}) 
					V=userdata
				else 

				end 

			end 
		else 
			if type(V) == "userdata" then  -- 如果查表查不到 且 表為userdada  不要 break  
			else 
				break
			end 
		end 
	end 

	--tab:each(function(elm)  print(elm[1],elm[2]) end ) 
	return tab 
end  
--localdata={env={zz=4,zc=5,abcd=3,abdd=2,acda=1,cc=7},tee={aa=3,bb=3,cc=5 }}
return rime_lua_debug
--return  debug("Ltee.abb.eb",1,{},localdata)
