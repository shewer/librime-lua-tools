#! /usr/bin/env lua
--
-- schema_func.lua
-- Copyright (C) 2020 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--
require 'tools/metatable'


local function getdata(config,key,datatype )
	datatype = datatype or "string"
	if "int" == datatype or "number" == datatype then 
		return config:get_int(key)
	elseif  "dobule" == datatype then 
		return config:get_double(key)
	elseif "bool"  == datatype or  "boolean" == datatype then 
		return config:get_bool(key)
	elseif "string" == datatype then 
		return config:get_string(key)
	else
	    return nil 
	end 
end 
local function get_list(config,key,datatype)
	datatype = datatype or "string"
	if not config:is_list(key) then return nil end 
	local tab=metatable()
	local list_size=config:get_list_size( key  )
	local tab=metatable()
	for i=0,(list_size -1) , 1 do
		tab:insert(  getdata( config, key .. "/@" .. i, datatype ) )
	end 
	return tab

end


local function get_data(config,key,datatype,list) 
		if list then 
			return get_list(config,key,datatype)
		else 
			return getdata(config,key,datatype)
		end
end 

local function setdata(config,key,data , datatype )
	datatype = datatype or type(data) 
	if "int" == datatype or "number" == datatype then 
		 config:set_int(key,data)
	elseif  "dobule" == datatype then 
		 config:set_double(key,data)
	elseif "bool"  == datatype or  "boolean" == datatype then 
		 config:set_bool(key,data)
	elseif "string" == datatype then 
		config:set_string(key,data )
	else
	    return nil 
	end 
end 
local function set_list(config,key,datas,datatype)
	for i,data in next,datas  do
		datatype = datatype or "string"
		setdata( config, key .. "/@" .. i-1, data ,datatype ) 
	end 
end

local function set_data(config,key,datas,datatype ) 
	   	
		log.info( "-------".. __FUNC__() .. debug.getinfo(2,"fuSln").name .. type(datas)  ) 
		if type(datas) == "table"  then 
			set_list(config,key,datas,datatype)
		else 
			setdata(config,key,datas, datatype)
		end
end
--     
local function load_user_data(config,path,data_table)
	path = path and path .. "/"  or "" 
	local tab=metatable({path=path })

	for k,v in pairs(data_table) do 
		-- clone data_table
		tab[k]= get_data(config, path ..  v.name , v.type,v.list ) 
	end 
	return tab 
end 

return { 
	get_data=get_data , 
	get_list=get_list,
	set_data=set_data,
	set_list=set_list,
	load_user_data=load_user_data,  
} 

--[[
  get_data(config,path,data,datatype,list_f)   list_f == true/false nil 
  get_list(config,path,list_data, datatype)
  set_data(config,path,data,datatype)
  set_list(config,path,list_data, datatype)  -- data : table 
  load_user_data(config, tab)

  get_data(config,"engine/translators","string",true )    -- get list of string
  get_data(config,"translator,"dictiona", "string" )      -- get  string
  set_data(config,"translator/test", 4 , "int")
  set_data(config,"trr" , {3,4,65,6,6}, "int")

  get_list(config,"engine/translators","string")
  set_list(config,"engine/translators",{"lua_translator","table_translator"} ,"string")


 load_user_data(config, user_data_table)  

 {


--
--]]


