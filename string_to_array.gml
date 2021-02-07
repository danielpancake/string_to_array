/// @function string_to_array(input, len)
/// @argument {string} input String to split into characters array
/// @argument {real} len Length of the given string
/// @returns {array} Returns an array of characters
/*
	Author: danielpancake
	Date: 07.02.21
	
	https://danielpancake.github.io
*/

function string_to_array(input, len) {
	var array = array_create(len, "");
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
			char = (char<<6) | (buffer_peek(buffer, i + jj, buffer_u8)&63);
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