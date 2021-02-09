/// @function string_to_array(input, length)
/// @description This function converts a string to a character array using a buffer and utf-8 byte encoding
/// @argument {string} input String to split into characters array
/// @argument {number} length The length of the given string
/// @returns {array} Returns an array of characters
/*
	Author: danielpancake
	Date: 07.02.21

	https://danielpancake.github.io
*/
function string_to_array(input, length) {
	var array = array_create(length, "");
	var char_index = 0;
	
	var i = 0;
	var input_length = string_byte_length(input);
	
	// Create a buffer
	var buffer = buffer_create(input_length, buffer_fixed, 1);
	buffer_seek(buffer, buffer_seek_start, 0);
	buffer_write(buffer, buffer_text, input);
	
	// Going through all bytes in the string
	while (i < input_length) {
		var byte = buffer_peek(buffer, i, buffer_u8);
		var j = 0;
		
		// The last valid Unicode character starts with a byte _11110_100
		// so we only care about the first five digits in the first byte
		repeat (5) {
			if (byte&(128>>j) == 0) {
				break;
			} else {
				j++;
			}
		}
		
		var jj = 1;
		
		// Getting the unicode code of a character
		var char = byte&(255>>j);
		repeat (j - 1) {
			var peek = buffer_peek(buffer, i + jj, buffer_u8);
			char = (char<<6) | (peek&63);
			jj++;
		}
		
		// Writing the character to an array
		array[char_index++] = chr(char);
		
		// If the character is encoded with only one byte, go to the next
		if (j == 0) { i++; } else { i += j; }
	}
	
	buffer_delete(buffer);
	return array;
}

/*
	Additional functions for working with character arrays

	These functions are designed similarly to the string_* gml functions
	Note that unlike gml strings, character arrays start at index 0, not 1
	Most char_array_* functions have a "safe" argument. When this argument is true,
	index doesn't leave the bounds of the character array, and therefore function won't throw an error
*/

/// @function char_array_string(array, index, count, safe)
/// @description This function returns a string from a slice of the given character array
/// @argument {array} array The array of characters to make string from
/// @argument {number} index The position of the first character in the array to copy from
/// @argument {number} count The number of characters, starting from the position of the first
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {string} Returns a string from a slice of the given character array
function char_array_string(array, index, count, safe) {
	if (count >= 0) {
		return char_array_string_range(array, index, index + count, safe);
	} else {
		return char_array_string_range(array, index + count + 1, index + 1, safe);
	}
}

/// @function char_array_string_range(array, from, to, safe)
/// @description This function returns a string from a slice of the given character array
/// @argument {array} array The array of characters to make string from
/// @argument {number} from The position of the first character in the array
/// @argument {number} to The position of the last character in the array
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {string} Returns a string from a slice of the given character array
function char_array_string_range(array, from, to, safe) {
	var output = "";
	
	if (safe) {
		var length = array_length(array);
		from = clamp(from, 0, length - 1);
		to = clamp(to, 1, length);
	}
	
	for (var i = from; i < to; i++) {
		output += array[i];	
	}
	
	return output;
}

/// @function char_array_count(array, index, count, char, safe)
/// @description This function returns the amount of times the given character appears within a slice of the given character array
/// @argument {array} array The array of characters to check in
/// @argument {number} index The position of the first character in the array to count from
/// @argument {number} count The number of characters, starting from the position of the first
/// @argument {string} char The character to check
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {string} Returns the amount of times the given character appears within a slice of the character array
function char_array_count(array, index, count, char, safe) {
	if (count >= 0) {
		return char_array_count_range(array, index, index + count, char, safe);
	} else {
		return char_array_count_range(array, index + count + 1, index + 1, char, safe);
	}
}

/// @function char_array_count_range(array, from, to, char, safe)
/// @description This function returns the amount of times the given character appears within a slice of the given character array
/// @argument {array} array The array of characters to check in
/// @argument {number} from The position of the first character in the array
/// @argument {number} to The position of the last character in the array
/// @argument {string} char The character to check
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {string} Returns the amount of times the given character appears within a slice of the character array
function char_array_count_range(array, from, to, char, safe) {
	var count = 0;
		
	if (safe) {
		var length = array_length(array);
		from = clamp(from, 0, length - 1);
		to = clamp(to, 1, length);
	}
	
	for (var i = from; i < to; i++) {
		if (array[i] == char) count++;
	}
	
	return count;
}

/// @function char_array_pos(array, index, count, char, safe)
/// @description This function returns the character position within a slice of the given character array
/// @argument {array} array The array of characters to check in
/// @argument {number} index The position of the first character in the array to search from
/// @argument {number} count The number of characters, starting from the position of the first
/// @argument {string} char The character to check
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {number} Returns position of the given character within a slice of the character array
function char_array_pos(array, index, count, char, safe) {
	if (count >= 0) {
		return char_array_pos_range(array, index, index + count, char, safe);
	} else {
		return char_array_pos_range(array, index + count + 1, index + 1, char, safe);
	}
}

/// @function char_array_pos_range(array, from, to, char, safe)
/// @description This function returns the character position within a slice of the given character array
/// @argument {array} array The array of characters to check in
/// @argument {number} from The position of the first character in the array
/// @argument {number} to The position of the last character in the array
/// @argument {string} char The character to check
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {number} Returns position of the given character within a slice of the character array
function char_array_pos_range(array, from, to, char, safe) {
	var pos = -1;
	
	if (safe) {
		var length = array_length(array);
		from = clamp(from, 0, length - 1);
		to = clamp(to, 1, length);
	}
	
	for (var i = from; i < to; i++) {
		if (array[i] == char) {
			pos = i;
			break;
		}
	}
	
	return pos;
}

/// @function char_array_delete(array, length, index, count)
/// @description This function can be used to remove a specific part of the given character array
/// @argument {array} array The array of characters to delete from
/// @argument {number} index The position of the first character in the array to delete from
/// @argument {number} count The number of characters, starting from the position of the first
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {array} Returns new array without the specified part in it
function char_array_delete(array, index, count, safe) {
	if (count >= 0) {
		return char_array_delete_range(array, index, index + count, safe);
	} else {
		return char_array_delete_range(array, index + count + 1, index + 1, safe);
	}
}

/// @function char_array_delete_range(array, length, index, count)
/// @description This function can be used to remove a specific part of the given character array
/// @argument {array} array The array of characters to delete from
/// @argument {number} from The position of the first character in the array
/// @argument {number} to The position of the last character in the array
/// @argument {bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {array} Returns new array without the specified part in it
function char_array_delete_range(array, from, to, safe) {
	var length = array_length(array);
		
	if (safe) {
		from = clamp(from, 0, length - 1);
		to = clamp(to, 1, length);
	}
	
	var out = array_create(length + from - to, "-1");
	array_copy(out, 0, array, 0, from);
	array_copy(out, from, array, to, length - to);
	return out;
}