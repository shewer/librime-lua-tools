

local tools={
__FILE__ function() return debug.getinfo(2, 'S').source end,
__LINE__ function() return debug.getinfo(2, 'l').currentline end,
__FUNC__ function() return debug.getinfo(2, 'n').name end,
__FUNCd__ function() return debug.getinfo(1, 'n').name end,

}




return tools

