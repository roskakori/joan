indexing
   description: "Exception handling facilties.";
   pattern: "Singleton";

class EXCEPTIONS_SINGLETON

inherit 
   EXCEPTIONS;
   SINGLETON;
   
creation {ANY} 
   make

feature {ANY} -- Initialization

   make is 
      do  
         register_in_system;
      end -- make

feature {ANY} 
   
   die_screaming(last_will: STRING) is 
      -- Print `last_will' to `std_error' and exit with error code.
      require 
         last_will /= Void; 
         not last_will.is_empty; 
      do  
         std_error.put_string(last_will);
         std_error.put_new_line;
         die(10);
      end -- die_screaming

end -- class EXCEPTIONS_SINGLETON
