indexing
	description: "Make ugly SmallEiffel-gnerated C source a bit nicer.";

class JOAN

inherit 
	GLOBALS;
	CLASS_NAMES;
	JOAN_OPTIONS;
	SHARED_EXCEPTIONS;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		-- Do it.
		do  
			options.set_from_arguments;
			options.set_status_level(options.Status_verbose);
			check_existence(options.name + ".id");
			check_existence(options.name + ".c");
			check_existence(options.name + ".h");
			temporary_file_name := options.name + ".tmp";
			options.put_normal("reading id file");
			run_control.compute_root_class(options.name);
			options.put_normal("analyzing C source");
			remove_old_vahunz;
			make_vahunz_files;
			run_vahunz;
			options.put_normal("computing nice class names");
			Class_names.put_nice_items;
			options.put_normal("computing nice feature names");
			make_patterns;
			make_nice_names;
			options.put_normal("renaming C source");
			run_vahunz;
			options.put_normal("indenting C source");
			make_indented;
		end -- make

feature {NONE} 
	-- Implementation

	c_source_file_names: ARRAY[STRING];
	
	patterns: ARRAY[JOAN_PATTERN];
	
	basic_directory: BASIC_DIRECTORY;
		-- Provide low level access to directories.
	
	make_patterns is 
		-- Make internal conversion patterns.
		do  
			!!patterns.make(1,0);
			add_pattern("r#*","$_*");
			add_pattern("T#","T_$");
			add_pattern("f#*","frame_descriptor_of_$_*");
			add_pattern("ms#*","manifest_string_in_$*");
			add_pattern("se_prinT#", "se_print_$")
			add_pattern("store#", "store_$")
			add_pattern("store_chunk#", "store_chunk_$")
			add_pattern("store_left#", "store_left_$")
			add_pattern("new#", "new_$")
			add_pattern("gc#", "gc_$")
			add_pattern("gc_free#", "gc_free_$")
			add_pattern("gc_mark#", "gc_mark_$")
			add_pattern("gc_sweep#", "gc_sweep_$")
			add_pattern("gc_align_mark#", "gc_align_mark_$")
		ensure 
			patterns /= Void; 
			patterns.count > 0; 
		end -- make_patterns
	
	add_pattern(new_pattern, new_rule: STRING) is 
		-- Add pattern `new_pattern' with `rule' for conversion
		-- to `patterns'.
		require 
			patterns /= Void; 
		local 
			some: JOAN_PATTERN;
		do  
			!!some.make(new_pattern,new_rule);
			patterns.add_last(some);
		ensure 
			patterns.count = old patterns.count + 1; 
		end -- add_pattern
	
	quiet: BOOLEAN is false;
	
	remove_old_vahunz is 
		-- Remove possible files from a previous vahunzation.
		do  
			file_tools.delete(vahunz_files);
			file_tools.delete(vahunz_names);
			file_tools.delete(vahunz_ignore);
		end -- remove_old_vahunz
	
	make_vahunz_files is 
		-- Make "*.files".
		local 
			target: STD_FILE_WRITE;
			target_name: STRING;
			i: INTEGER;
		do  
			!!c_source_file_names.make(1,0);
			c_source_file_names.add_last(system_tools.path_h);
			c_source_file_names.add_last(options.name + ".c");
			target := connect_to_write_or_die(options.name + ".files");
			from 
				i := 1;
			until 
				i = c_source_file_names.count + 1
			loop 
				target.put_string(c_source_file_names.item(i));
				target.put_new_line;
				i := i + 1;
			end; 
			target.disconnect;
		ensure 
			c_source_file_names /= Void; 
			c_source_file_names.count > 1; 
		end -- make_vahunz_files
	
	make_nice_names is 
		-- Make "*.files".
		local 
			source: STD_FILE_READ;
			target: STD_FILE_WRITE;
			source_name, target_name: STRING;
			equal_index: INTEGER;
			line: STRING;
			i: INTEGER;
			pattern: JOAN_PATTERN;
		do  
			source_name := vahunz_names;
			target_name := temporary_file_name;
			options.put_debug("   source = " + source_name);
			options.put_debug("   target = " + target_name);
			from 
				source := connect_to_read_or_die(source_name);
				target := connect_to_write_or_die(target_name);
			until 
				source.end_of_input
			loop 
				source.read_line;
				if not source.end_of_input and then not source.last_string.is_empty then 
					line := source.last_string;
					equal_index := line.first_index_of('=');
					if equal_index /= 0 then 
						line.remove_last(line.count - equal_index);
					end; 
					target.put_string(line);
					if not line.is_empty and then line.first = ' ' then 
						line.remove_first(1);
						from 
							i := 1;
						until 
							i = patterns.count + 1
						loop 
							pattern := patterns.item(i);
							if pattern.matches(line) then 
								pattern.convert(line);
								target.put_character('=');
								target.put_string(pattern.last_converted);
								options.put_verbose("   " + line + " -> " + pattern.last_converted);
							end; 
							i := i + 1;
						end; 
					end; 
					target.put_new_line;
				end; 
			end; 
			target.disconnect;
			source.disconnect;
			file_tools.delete(source_name);
			file_tools.rename_to(target_name,source_name);
		end -- make_nice_names
	
	run_vahunz is 
		-- Run "vahunz" tool.
		local 
			vahunz: STRING;
		do  
			vahunz := clone("vahunz");
			vahunz.append(" --quiet --name-length 2");
			if false then 
				vahunz.append(" --comment");
			end; 
			vahunz.append(" --output " + vahunz_directory);
			vahunz.append(" --base-name " + options.name);
			run_program(vahunz);
		end -- run_vahunz
	
	make_indented is 
		-- Indent all items in `c_source_file_names' using GNU indent.
		local 
			indent: STRING;
			file_name: STRING;
			i: INTEGER;
		do  
			from 
				i := 1;
			until 
				i = c_source_file_names.count + 1
			loop 
				file_name := c_source_file_names.item(i);
				indent := clone("indent ");
				indent.append(path_in_vahunz(file_name));
				indent.append(" -o " + file_name);
				indent.append(" " + options.indent_options);
				run_program(indent);
				i := i + 1;
			end; 
		end -- make_indented
	
	temporary_file_name: STRING;

feature {NONE} 
	-- Implementation

	check_existence(file_name: STRING) is 
		-- Check that file with name `file_name' exists.
		-- If not, `die_screaming'.
		require 
			file_name /= Void; 
		do  
			if not file_tools.is_readable(file_name) then 
				Exceptions.die_screaming("file %"" + file_name + "%" must exist and be readable");
			end; 
		end -- check_existence
	
	run_program(some: STRING) is 
		-- Run external program, and set `exit_code'.
		require 
			some /= Void; 
		do  
			options.put_verbose("   " + some);
			exit_code := c_system(some.to_external);
			if exit_code /= 0 then 
				Exceptions.die_screaming("error code " + exit_code.to_string + " when running %"" + some + "%"");
			end; 
		end -- run_program
	
	exit_code: INTEGER;
	
	c_system(some: POINTER): INTEGER is 
		external "C"
		alias "system"
		end -- c_system

feature {NONE} 
	-- Implementation

	connect_to_write_or_die(file_name: STRING): STD_FILE_WRITE is 
		do  
			!!Result.connect_to(file_name);
			if not Result.is_connected then 
				Exceptions.die_screaming("cannot write to %"" + file_name + "%"");
			end; 
		ensure 
			Result.is_connected; 
		end -- connect_to_write_or_die
	
	connect_to_read_or_die(file_name: STRING): STD_FILE_READ is 
		do  
			!!Result.connect_to(file_name);
			if not Result.is_connected then 
				Exceptions.die_screaming("cannot read from %"" + file_name + "%"");
			end; 
		ensure 
			Result.is_connected; 
		end -- connect_to_read_or_die
	
	vahunz_directory: STRING is 
		-- directory where the vahunzed source codes end up
		once 
			if system_tools.system_name.is_equal("Amiga") then 
				Result := "t:vahunzed";
			else 
				Result := "vahunzed";
			end; 
		end -- vahunz_directory
	
	path_in_vahunz(file_name: STRING): STRING is 
		do  
			basic_directory.compute_file_path_with(vahunz_directory,file_name);
			Result := clone(basic_directory.last_entry);
		end -- path_in_vahunz
	
	vahunz_names: STRING is 
		once 
			Result := options.name + ".names";
		end -- vahunz_names
	
	vahunz_files: STRING is 
		once 
			Result := options.name + ".files";
		end -- vahunz_files
	
	vahunz_ignore: STRING is 
		once 
			Result := options.name + ".ignore";
		end -- vahunz_ignore

end -- class JOAN
