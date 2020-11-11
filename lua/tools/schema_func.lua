#! /usr/bin/env lua
--
-- schema_func.lua
-- Copyright (C) 2020 Shewer Lu <shewer@gmail.com>
--
-- Distributed under terms of the MIT license.
--


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
	local tlocal ab=metatable()
	local list_size=config:get_list_size( key  )
	local tab=metatable()
	for i=0,(list_size -1) , 1 do
		tab:insert(  getdata( config, key .. "/@" .. i, datatype ) )
	end 
	return tab

end
local function get_data(config,key,datatype,datatype1) 
		if datatype== "list" then 
			return get_list(config,key,datatype1)
		else 
			return getdata(config,key,datatype)
		end
end 
local function set_data(config,key,datatype,datatype1)


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
	for i=0,(#datas -1) , 1 do
		datatype = datatype or "string"
		setdata( config, key .. "/@" .. i, data ,datatype ) 
	end 
end

local function set_data(config,key,datas,datatype ) 
	   	
		log.info( "-------".. __FUNC__() .. debug.getinfo(2,"fuSln").name .. type(datas)  ) 
		if datas == "table"  then 
			set_list(config,key,datas,datatype)
		else 
			setdata(config,key,datas, datatype)
		end
end



return {get_data=get_data , get_list=get_list,set_data=set_data,set_list=set_list  } 
