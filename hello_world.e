class HELLO_WORLD

creation
	make

feature -- Initialization

	make is
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i = 11
			loop
				put_hello_world
				i := i + 1
			end
		end -- make

	put_hello_world is
		do
			io.put_string("hello world");
			io.put_new_line
		end;

end -- class HELLO_WORLD

