indexing
	description: "Test JOAN_PATTERN";

class TEST_JOAN_PATTERN

inherit 
	GLOBALS
	CLASS_NAMES;
	SHARED_EXCEPTIONS;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make is 
		do  
			run_control.compute_root_class("test_joan_pattern")
			io.put_string("generating nice class names")
			io.put_new_line;
			Class_names.put_nice_items
			test_pattern("r#*","$_*","r7append","STRING_append");
			test_pattern("r#*","$_*","r_append",Void);
			test_pattern("se_prinT#","se_print_$","se_prinT7x",Void);
			test_pattern("se_prinT#","se_print_$","se_prinT7","se_print_STRING");
			test_pattern("T#","T_$","T7","T_STRING");
		end -- make
	
	test_pattern(pattern, rule, source, expectation: STRING) is 
		local 
			testing: JOAN_PATTERN;
			matches: BOOLEAN;
		do  
			!!testing.make(pattern,rule);
			io.put_string("test_pattern");
			io.put_new_line;
			io.put_string("   pattern=" + pattern);
			io.put_new_line;
			io.put_string("   rule   =" + rule);
			io.put_new_line;
			io.put_string("   source =" + source);
			io.put_new_line;
			if expectation /= Void then 
				io.put_string("   expect =" + expectation);
				io.put_new_line;
			end; 
			matches := testing.matches(source);
			if matches then 
				if expectation /= Void then 
					testing.convert(source);
					io.put_string("   convert=" + testing.last_converted);
					io.put_new_line;
					if not expectation.is_equal(testing.last_converted) then
						io.put_string("   *** bug: converted does not match expectation");
						io.put_new_line;
					end; 
				else 
					io.put_string("   *** bug: pattern must not match");
					io.put_new_line;
				end; 
			elseif expectation /= Void then 
				io.put_string("   *** bug: pattern must match");
				io.put_new_line;
			end; 
		end -- test_pattern

end -- class TEST_JOAN_PATTERN
