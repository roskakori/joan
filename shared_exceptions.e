indexing
	description: "Accessor for exception handling facilities.";
	pattern: "Singleton accessor";

class SHARED_EXCEPTIONS

inherit 
	SINGLETON_ACCESSOR
		rename singleton as Exceptions
		end; 
	
feature {ANY} -- Access

	Exceptions: EXCEPTIONS_SINGLETON is 
		-- exception handling facilitities
		do  
			!!Result.make;
		end -- Exceptions

end -- class SHARED_EXCEPTIONS
