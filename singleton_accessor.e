indexing
   description: "Singleton accessor.";

deferred class SINGLETON_ACCESSOR

feature {ANY} -- Access

   singleton: SINGLETON is 
      deferred
      ensure 
         Result /= Void; 
      end -- singleton

end -- class SINGLETON_ACCESSOR
