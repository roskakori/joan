indexing
	description: "Class names from source code JOAN processes.";
	pattern: "Singleton accessor";

class CLASS_NAMES

inherit 
	GLOBALS;
	SINGLETON_ACCESSOR
		rename singleton as class_names
		end; 
	
feature {ANY} -- Access

	Class_names: CLASS_NAMES_SINGLETON is 
		require 
			run_control.root_class /= Void; 
			not run_control.root_class.is_empty; 
		once 
			!!Result.make;
		end -- Class_names

end -- class CLASS_NAMES
