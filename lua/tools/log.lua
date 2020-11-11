
local function  writefile(file,str )
	local fp=io.open(file,"a")
	io.output(fp)
	fp:write(str,"\n")
	fp:close()
end 

local function getfilename(str)
	local  tmp= os.getenv("TMP") or os.getenv("TEMP") or "c:/tmp"
	return  tmp .. "/librime-lua_" .. tostring(str)  .. os.date("_%Y%m%d.log") 
end    
local function write_log(logname,str)
		local filename=getfilename(logname)
		local msg= string.format("I%s: %s" , os.date("%Y%m%d %H%M%S"), tostring(str) )
		writefile(filename,msg)   
end 
local function errormsg(dtab)
	local line = dtab.currentline
	local fname= dtab.source
	local func=  dtab.name
	return  string.format("..%s:%s bad argum_#1 (string expected, got nil)",fname,line)  
end 


local function init( org_log) 
	local log_bypass= function(str)  end  
	org_log= org_log  or   { info=log_bypass, warning=log_bypass, error=log_bypass } 
	local log={}
	log.org_log=org_log   

	log.info = function(str) 
			org_log.info(str)
			write_log("info",str)
	end 
	log.warning=function(str)	
		org_log.warning(str)
		write_log("warning",str)
	end 
	log.error= function(str)
		org_log.error(str) 
		write_log("error",str)
	end 
	return log 
end 

return init 

