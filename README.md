# librime-lua-tools

## object.lua 
## metatable.lua
## schema_func.lua
   ```lua
      get_data(env.engine.schema.config, path , datatype )   
      get_data(env.engine.schema.config, path , datatype , list)   
	  set_data(env.engine.schema.config, path , data, datatype)   int double string 
	  set_data(env.engine.schema.config, path , table, datatype)  list of datatype
	  load_user_data(env.engine.schema.config, data_table)
	  --   data_table = { engine ={ 
	  
   ``

## notifier.lua:   Notifier 
  ```lua
     Notyfier=require 'tools/notifier'
	 function init(env)
	 	env.notifier=Notifier(env)
		env.notifier:commit( function(ctx)  end ) -- context.commit_notifier:connect(func)
		env.notifier:update( function(ctx) end )  -- context.update_notifier:connect(func) 
		env.notifier:select( function(ctx) end )  -- context.select_notifier:connect(func)
		env.notifier:delete( function(ctx) end )  -- context.delete_notifier:connect(func)
		env.notifier:option( function(ctx,name) end )  -- context.option_update_notifier:connect(func)
		env.notifier:property( function(ctx,name) end )  -- context.property_update_notifier:connect(func)
		env.notifier:unhandled_key( function(ctx) end )  -- context.unhandled_key_notifier:connect(func)
		
		
	end 
	function fini(env)
	    env.notifier:disconnect()  --  disconnect() for all connection() 
	end
``` 

	 


