#!/usr/bin/lua

-- recover pid of flashplayer
function pid()
	 local file = io.popen("ps x | grep flashplayer")

	 local lines = {}
	 
	 for line in file:lines() do
			return tonumber( line:match('%d+') )
	 end
end


-- list of opened files by pid matching filter
function fd( pid, filter )
	 local cmd = 'cd /proc/' .. pid .. '/fd; file -L *'
	 
	 if filter then cmd = cmd .. '|grep -i ' .. filter end

	 local file = io.popen( cmd )

	 local res = {}

	 for line in file:lines() do
			table.insert( res, tonumber( line:match('%d+') ) )
	 end

	 return res
end


p = pid()

cmd = {}

local doc = {}

function path( id )
	 return '/proc/' .. p .. '/fd/' .. id
end

doc.list = '[FILTER] \t list open file descriptor matching FILTER (default: flash)'
function cmd.list( filter )
	 filter = filter or 'flash'
	 
	 for _, v in pairs( fd( p , filter )) do
			print( v )
	 end
end
 
doc.open = 'ID \t\t open file with descriptor ID'
function cmd.open( id )
	 os.execute('xdg-open ' .. path(id) )
end

doc.save = 'ID [FILENAME] \t save file with descriptor ID to FILENAME (default: /tmp/flvsave)'
function cmd.save( id, filename )
	 filename = filename or '/tmp/flvsave'
	 os.execute( 'cp -H ' .. path(id) .. ' ' .. filename )
end

doc.help = '\t\t show this help message'


function cmd.help()
	 print( 'usage: ' .. arg[0] .. ' command [args] ... command [args]' )
	 print( 'available commands:')
	 for c, _ in pairs( cmd ) do
			print( c, doc[c] )
	 end
end



-- turns args into a map of commands
function process()
	 local todo = {}
	 
	 local args = nil

	 for i = 1, #arg do
			local a = arg[i]

			if cmd[a] then
				 args = {}
				 todo[ cmd[a] ] = args
			elseif args then
				 table.insert(args, a)
			end
	 end

	 for c, args in pairs(todo) do
			c( unpack(args) )
	 end
	 
end

process()

if #arg == 0 then cmd.help() end



