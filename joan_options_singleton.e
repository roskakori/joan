indexing
	description: "Options for JOAN";
	pattern: "Singleton";

class JOAN_OPTIONS_SINGLETON

inherit 
	SHARED_EXCEPTIONS;
	SINGLETON;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		-- Set default values.
		do  
			status_level := Status_normal;
			indent_options := "--indent-level3 --braces-on-if-line --cuddle-else --space-after-cast --else-endif-column1 --swallow-optional-blank-lines --start-left-side-of-comments --continue-at-parentheses --tab-size3 --no-space-after-function-call-names"
			register_in_system
		end -- make

feature {ANY} -- Access

	status_level: INTEGER;
		-- How much status messages should be shown?
	
	Status_quiet, Status_normal, Status_verbose, Status_debug: INTEGER is unique;
		-- possible value for `status_level'
	
	indent_options: STRING;
		-- options to be passed to indent
	
	name: STRING;
		-- base name for files (root class name)
	
feature {ANY} -- Status change

	set_from_arguments is 
		-- Set options from `argument'. In case of error, `die_screaming'.
		local 
			new_name: STRING;
			i: INTEGER;
			c: CHARACTER;
		do  
			if argument_count = 1 then 
				new_name := argument(1).twin;
				new_name.to_lower;
				from 
					i := 1;
				until 
					i = new_name.count + 1 or else new_name.item(i) = '.'
				loop 
					c := new_name.item(i);
					inspect 
						c
					when 'a'..'z','0'..'9','_' then 
							do_nothing
					else  Exceptions.die_screaming("base name must contain only letters, digits and underscores (_)");
					end; 
					i := i + 1;
				end; 
				new_name.remove_last(new_name.count + 1 - i);
				if new_name.is_empty then 
					Exceptions.die_screaming("base name must contain at least one character (excluding file name extension)");
				end; 
				set_name(new_name);
			else 
				Exceptions.die_screaming("base name must be specified");
			end; 
		end -- set_from_arguments
	
	set_name(some: STRING) is 
		-- Set `name' to `some'.
		require 
			name_not_void: some /= Void; 
		do  
			name := some;
		ensure 
			name_set: name = some; 
		end -- set_name
	
	set_indent_options(some: STRING) is 
		-- Set `indent_options' to `some'.
		require 
			indent_options_not_void: some /= Void; 
		do  
			indent_options := some;
		ensure 
			indent_options_set: indent_options = some; 
		end -- set_indent_options
	
	set_status_level(some: INTEGER) is 
		-- Set `status_level' to `some'.
		require 
			some.in_range(Status_quiet,Status_debug); 
		do  
			status_level := some;
		ensure 
			status_level_set: status_level = some; 
		end -- set_status_level
	
	put_normal(message: STRING) is 
		-- Put normal status `message' on screen.
		require 
			message /= Void; 
		do  
			if status_level /= Status_quiet then 
				io.put_string(message);
				io.put_new_line;
			end; 
		end -- put_normal
	
	put_verbose(message: STRING) is 
		-- Put verbose status `message' on screen.
		require 
			message /= Void; 
		do  
			if status_level > Status_normal then 
				io.put_string(message);
				io.put_new_line;
			end; 
		end -- put_verbose
	
	put_debug(message: STRING) is 
		-- Put debugging status `message' on screen.
		require 
			message /= Void; 
		do  
			if status_level > Status_verbose then 
				io.put_string(message);
				io.put_new_line;
			end; 
		end -- put_debug

end -- class JOAN_OPTIONS_SINGLETON
