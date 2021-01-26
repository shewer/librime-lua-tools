

local tools={
__FILE__ = function(level) return debug.getinfo(level or 2, 'S').source end,
__LINE__ = function(level) return debug.getinfo(level or 2, 'l').currentline end,
__FUNC__ = function(level) return debug.getinfo(level or 2, 'n').name end,

}




return tools

