class SINGLETON

feature {NONE} -- Initialization

	frozen register_in_system is 
		-- Register an an instance of this singleton. This
		-- feature must be called in every creation feature of
		-- every subclass of SINGLETON in order to fulfill the
		-- invariant `is_singleton'.
		require 
			no_previous_instance: not singletons_in_system.has(generator); 
		do  
			singletons_in_system.put(Current,generator);
		end -- frozen register_in_system

feature {NONE} -- Implementation

	frozen singletons_in_system: DICTIONARY[ANY,STRING] is
		-- Table containing all system singletons hashed by
		-- generator name
		once 
			!!Result.make;
		end -- frozen singletons_in_system

invariant 
	
	is_singleton: singletons_in_system.has(generator); 

end -- class SINGLETON
