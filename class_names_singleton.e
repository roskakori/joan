indexing
	description: "Nice and ugly class names for certain id's.";
	pattern: "Singleton";

class CLASS_NAMES_SINGLETON

inherit 
	GLOBALS;
	JOAN_OPTIONS;
	SHARED_EXCEPTIONS;
	SINGLETON
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		require 
			run_control.root_class /= Void; 
			not run_control.root_class.is_empty; 
		local 
			id_file_name: STRING;
		do  
			id_file_name := system_tools.id_file_path;
			if not file_tools.is_readable(id_file_name) then 
				Exceptions.die_screaming("id file %"" + id_file_name + "%" must exist");
			end; 
			nice_class_names := Void;
			register_in_system
		end -- make

feature {ANY} -- Access

	nice_item(id: INTEGER): STRING is 
		-- nice class name for mangled `id'
		require 
			id.in_range(lower,upper); 
		do  
			Result := nice_class_names.item(id);
		end -- nice_item
	
	ugly_item(id: INTEGER): STRING is 
		-- ugly class name for mangled `id' used internal by
		-- SmallEiffel when generating C code
		require 
			id.in_range(lower,upper); 
		do  
			Result := id_provider.alias_of(id);
		ensure 
			Result /= Void; 
		end -- ugly_item
	
	lower: INTEGER is 0;
	
	upper: INTEGER is 
		do  
			Result := id_provider.max_id;
		end -- upper

feature {ANY} -- Status change

	put_nice_items is 
		-- Compute all names for `nice_item' according to information
		-- in `ugly_item'.
		local 
			i: INTEGER;
			class_name: STRING;
		do  
			from 
				i := 0;
				!!nice_class_names.make(0,upper);
			until 
				i = upper + 1
			loop 
				class_name := ugly_item(i);
				nice_class_names.put(nice_class_name_for(class_name),i);
				if true then 
					options.put_verbose("  " + i.to_string + ": " + class_name + " -> " + nice_class_names.item(i));
				end; 
				i := i + 1;
			end; 
		end -- put_nice_items

feature {NONE} 
	-- Implementation

	nice_class_names: ARRAY[STRING];
	
	nice_class_name_for(class_name: STRING): STRING is 
		-- Compute nice routine name for class with name `class_name'.
		-- Make result availavle in `last_nice_class'
		local 
			i, j: INTEGER;
			c: CHARACTER;
			generic_nesting: INTEGER;
		do  
			from 
				i := 1;
				!!Result.make(0);
			until 
				i = class_name.count + 1
			loop 
				c := class_name.item(i);
				inspect 
					c
				when 'a'..'z','A'..'Z','0'..'9','_' then 
						Result.extend(c)
				when ' ' then 
						do_nothing
				when '[' then 
						generic_nesting := generic_nesting + 1;
						Result.append("_of_")
				when ']' then 
						if false then 
							Result.append("__")
						end 
						generic_nesting := generic_nesting - 1
				when ',' then 
						Result.append("_and_")
				else  Exceptions.die_screaming("cannot translate class name %"" + class_name + "%" at character " + i.to_string);
				end; 
				i := i + 1;
			end; 
		ensure 
			Result /= Void; 
			not Result.is_empty; 
		end -- nice_class_name_for

end -- class CLASS_NAMES_SINGLETON
