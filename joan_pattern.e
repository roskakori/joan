indexing
	description: "Pattern and rule to convert ugly name to nice one.";

class JOAN_PATTERN

inherit 
	CLASS_NAMES;
	SHARED_EXCEPTIONS;
	
creation {ANY} 
	make

feature {ANY} -- Initialization

	make(new_pattern, new_rule: STRING) is 
		-- Make pattern `new_pattern' with `new_rule' for expansion.
		require 
			new_pattern /= Void; 
			new_pattern.has_suffix("#") or new_pattern.has_suffix("#*"); 
			new_rule.has('$'); 
			new_pattern.has('*') implies new_rule.has('*'); 
		local 
			i: INTEGER;
		do  
			pattern := new_pattern.twin;
			rule := new_rule.twin;
			!!pattern_before_id.make(0);
			!!pattern_after_id.make(0);
			!!ugly_after_id.make(32);
			has_asterisk := pattern.has('*');
			split_at_hash(pattern,pattern_before_id,pattern_after_id);
		ensure 
			pattern.is_equal(new_pattern); 
			rule.is_equal(new_rule); 
		end -- make

feature {ANY} -- Access

	pattern: STRING;
		-- pattern ugly name has to match to be convertable;
		-- '#' represents class id, '*' represents suffix
	
	rule: STRING;
		-- conversion rule to turn ugly name into a nice one;
		-- '$' represents class name, '*' represents suffix
	
	matches(some: STRING): BOOLEAN is 
		-- Does `some' match `pattern'?
		require 
			some /= Void; 
			not some.is_empty; 
		local 
			i: INTEGER;
		do  
			if some.has_prefix(pattern_before_id) then 
				set_id_index(some,pattern_before_id.count + 1);
				Result := first_id_index > 0;
				if Result and not has_asterisk then 
					Result := last_id_index = some.count;
				end; 
			end; 
			-- Exceptions.raise("stopping")
		end -- matches

feature {ANY} -- Conversion

	last_converted: STRING;
	
	convert(ugly_name: STRING) is 
		-- Convert `ugly_name' to nice one, and make result available
		-- in `last_converted'.
		require 
			ugly_name /= Void; 
			not ugly_name.is_empty; 
			matches(ugly_name); 
			Class_names.upper > 0; 
		local 
			i, j: INTEGER;
			c: CHARACTER;
			asterisk_index: INTEGER;
		do  
			if last_converted = Void then 
				!!last_converted.make(64);
			else 
				last_converted.clear;
			end; 
			asterisk_index := ugly_name.first_index_of('*');
			set_id_index(ugly_name,pattern_before_id.count + 1);
			from 
				ugly_after_id.clear;
				i := last_id_index + 1;
			until 
				i = ugly_name.count + 1
			loop 
				ugly_after_id.extend(ugly_name.item(i));
				i := i + 1;
			end; 
			from 
				i := 1;
			until 
				i = rule.count + 1
			loop 
				c := rule.item(i);
				inspect 
					c
				when '$' then 
						last_converted.append(Class_names.nice_item(last_id))
				when '*' then 
						last_converted.append(ugly_after_id)
				else  last_converted.extend(c);
				end; 
				i := i + 1;
			end; 
		ensure 
			last_converted /= Void; 
			not last_converted.is_empty; 
		end -- convert

feature {NONE} 
	-- Implementation

	split_at_hash(some, before, after: STRING) is 
		-- Split `some' at '#' and store result in `before'
		-- and `after'.
		require 
			some /= Void; 
			some.has('#'); 
			before /= Void; 
			after /= Void; 
		local 
			hash_index: INTEGER;
		do  
			hash_index := some.first_index_of('#');
			before.copy(some.substring(1,hash_index - 1));
			after.copy(some.substring(hash_index + 1,some.count));
		end -- split_at_hash
	
	last_id, first_id_index, last_id_index: INTEGER;
		-- Result of `set_id_index'
	
	set_id_index(some: STRING; start_index: INTEGER) is 
		-- Set `first_id_index' and `last_id_index' to index range
		-- in some where there are decima digits, starting from
		-- `start_index'. Set `last_id' to decimal value represented
		-- by this substring.
		--
		-- If there are no decimal digits, or `some' is too short,
		-- set both `first_id_index' and `last_id_index' to 0.
		require 
			some /= Void; 
			start_index.in_range(1,some.count + 1); 
		local 
			has_id: BOOLEAN;
		do  
			if some.count >= start_index and then some.item(start_index).is_digit then
				from 
					first_id_index := start_index;
					last_id_index := start_index;
					last_id := 0;
				until 
					last_id_index = some.count + 1 or else not some.item(last_id_index).is_digit
				loop 
					last_id := 10 * last_id + some.item(last_id_index).value;
					last_id_index := last_id_index + 1;
				end; 
				has_id := last_id.in_range(Class_names.lower,Class_names.upper);
			end; 
			-- Exceptions.raise("stopping")
			if has_id then 
				last_id_index := last_id_index - 1;
			else 
				first_id_index := 0;
				last_id_index := 0;
				last_id := 0;
			end; 
		ensure 
			first_id_index.in_range(0,some.count); 
			last_id_index.in_range(0,some.count); 
			last_id.in_range(0,Class_names.upper); 
			first_id_index > 0 implies last_id = some.substring(first_id_index,last_id_index).to_integer; 
			first_id_index = 0 implies last_id = 0 and last_id_index = 0; 
		end -- set_id_index
	
	pattern_before_id: STRING;
		-- part of pattern before class id
	
	pattern_after_id: STRING;
		-- part of pattern after class id
	
	ugly_after_id: STRING;
		-- part of ugly name after after numeric class id
	
	has_asterisk: BOOLEAN;
		-- Do `pattern' and `rule' have an '*'?
	
end -- class JOAN_PATTERN
