/// @function string_to_array(input, len)
/// @argument {string} input String to split into characters array
/// @argument {real} len Length of the given string
/// @returns {array} Returns array of characters
/*
	Author: danielpancake
	Date: 07.02.21
	
	https://danielpancake.github.io
*/

function string_to_array(input, len) {
	var array = array_create(len, "");
	var char_index = 0;
	
	var i = 1;
	var input_length = string_byte_length(input);
	// Go through all bytes in the string
	while (i <= input_length) {
		var byte = string_byte_at(input, i);
		var j = 0;
		
		// Last legal unicode character starts with byte _11110_100
		// so we only care about first five digits in the first byte
		repeat (5) {
			if (byte&(128>>j) == 0) {
				break;	
			} else {
				j++;
			}
		}
		
		var jj = 1;
		
		// Get unicode code of the character
		var char = byte&(255>>j);
		repeat (j - 1) {
			char = (char<<6) | (string_byte_at(input, i + jj)&63);
			jj++;
		}
		
		// Write character to the array
		array[char_index++] = chr(char);
		
		// If character is encoded with only one byte, go to the next one
		if (j == 0) { i++; } else { i += j; }
	}
	
	return array;
}