indexing
	description: "Options for JOAN.";

class JOAN_OPTIONS

inherit 
	SINGLETON_ACCESSOR
		rename singleton as options
		end; 
	
feature {ANY} -- Initialization

	options: JOAN_OPTIONS_SINGLETON is 
		once 
			!!Result.make;
		end -- options

end -- class JOAN_OPTIONS
