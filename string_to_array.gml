/*
  Author: danielpancake
  Release date: 07.02.21
  Last updated: 28.07.23
  
  https://danielpancake.github.io
*/
/// @function string_to_array(_str, _length)
/// @description Converts a string to a character array using a buffer and utf-8 byte encoding
/// @argument {String} _str String to split into characters array
/// @argument {Real} _length The length of the given string
/// @returns {Array<String>} Returns an array of characters
function string_to_array(_str, _length) {
  var _output_arr = array_create(_length, chr(0));
  var _output_curr = 0;
  
  var _str_bytes = string_byte_length(_str);
  
  // Creating a buffer
  var _buff = buffer_create(_str_bytes, buffer_fixed, 1);
  buffer_seek(_buff, buffer_seek_start, 0);
  buffer_write(_buff, buffer_text, _str);
  
  // Allocating variables
  var _byte = 0;
  var _byte_offset = 0;
  var _byte_offset_ahead = 0;
  
  var _bit_offset = 0;
  
  var _char = chr(0);
  var _peek = 0;
  
  // Iterating through bytes
  while (_byte_offset < _str_bytes) {
    _byte = buffer_peek(_buff, _byte_offset, buffer_u8);
    
    // We will check the first byte of the sequence
    // to match how bytes a character occupies
    //
    // 0_xxxxxxx - 1 byte;
    // 110_xxxxx - 2 bytes;
    // 1110_xxxx - 3 bytes;
    // 11110_xxx - 4 bytes.
    //
    // Checking first 5 bits is enough
    _bit_offset = 0;
    repeat (5) {
      if (_byte & (128 >> _bit_offset)) { // bit is one
        _bit_offset += 1;
      } else { // bit is zero
        break;
      }
    }
    
    // TODO: Invalid byte handling maybe?
    
    _byte_offset_ahead = 0;
    
    _char = _byte & (255 >> _bit_offset);
    repeat (_bit_offset - 1) {
      _peek = buffer_peek(_buff, _byte_offset + _byte_offset_ahead, buffer_u8);
      
      // TODO: Invalid byte handling here? Bytes must begin with 10_xxxxxx
      
      // Adding bytes to the character sequence
      _char = (_char << 6) | (_peek & 63);
      _byte_offset_ahead += 1;
    }
    
    _output_arr[_output_curr] = chr(_char);
    _output_curr += 1;
    
    _byte_offset += min(1, _bit_offset);
  }
  
  buffer_delete(_buff);
  return _output_arr;
}

/*
  Additional functions for working with character arrays

  These functions are designed similarly to the string_* gml functions
  Note that unlike gml strings, character arrays start at index 0, not 1
  Most char_array_* functions have a "safe" argument. When this argument is true,
  index doesn't leave the bounds of the character array, and therefore function won't throw an error
*/

/// @function char_array_string(array, index, count, safe)
/// @description Returns a string from a slice of the given character array
/// @argument {Array<String>} array The array of characters to make string from
/// @argument {Real} index The position of the first character in the array to copy from
/// @argument {Real} count The number of characters, starting from the position of the first
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {String} Returns a string from a slice of the given character array
function char_array_string(array, index, count, safe) {
  if (count >= 0) {
    return char_array_string_range(array, index, index + count, safe);
  }
  
  return char_array_string_range(array, index + count + 1, index + 1, safe);
}

/// @function char_array_string_range(array, from, to, safe)
/// @description Returns a string from a slice of the given character array
/// @argument {Array<String>} array The array of characters to make string from
/// @argument {Real} from The position of the first character in the array
/// @argument {Real} to The position of the last character in the array
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {String} Returns a string from a slice of the given character array
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
/// @description Returns the amount of times the given character appears within a slice of the given character array
/// @argument {Array<String>} array The array of characters to check in
/// @argument {Real} index The position of the first character in the array to count from
/// @argument {Real} count The number of characters, starting from the position of the first
/// @argument {String} char The character to check
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Real} Returns the amount of times the given character appears within a slice of the character array
function char_array_count(array, index, count, char, safe) {
  if (count >= 0) {
    return char_array_count_range(array, index, index + count, char, safe);
  } else {
    return char_array_count_range(array, index + count + 1, index + 1, char, safe);
  }
}

/// @function char_array_count_range(array, from, to, char, safe)
/// @description Returns the amount of times the given character appears within a slice of the given character array
/// @argument {Array<String>} array The array of characters to check in
/// @argument {Real} from The position of the first character in the array
/// @argument {Real} to The position of the last character in the array
/// @argument {String} char The character to check
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Real} Returns the amount of times the given character appears within a slice of the character array
function char_array_count_range(array, from, to, char, safe) {
  var count = 0;
    
  if (safe) {
    var length = array_length(array);
    from = clamp(from, 0, length - 1);
    to = clamp(to, 1, length);
  }
  
  for (var i = from; i < to; i++) {
    count += real(array[i] == char);
  }
  
  return count;
}

/// @function char_array_pos(array, index, count, char, safe)
/// @description Returns the character position within a slice of the given character array
/// @argument {Array<String>} array The array of characters to check in
/// @argument {Real} index The position of the first character in the array to search from
/// @argument {Real} count The number of characters, starting from the position of the first
/// @argument {String} char The character to check
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Real} Returns position of the given character within a slice of the character array
function char_array_pos(array, index, count, char, safe) {
  if (count >= 0) {
    return char_array_pos_range(array, index, index + count, char, safe);
  } else {
    return char_array_pos_range(array, index + count + 1, index + 1, char, safe);
  }
}

/// @function char_array_pos_range(array, from, to, char, safe)
/// @description Returns the character position within a slice of the given character array
/// @argument {Array<String>} array The array of characters to check in
/// @argument {Real} from The position of the first character in the array
/// @argument {Real} to The position of the last character in the array
/// @argument {String} char The character to check
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Real} Returns position of the given character within a slice of the character array
function char_array_pos_range(array, from, to, char, safe) {
  if (safe) {
    var length = array_length(array);
    from = clamp(from, 0, length - 1);
    to = clamp(to, 1, length);
  }
  
  for (var i = from; i < to; i++) {
    if (array[i] == char) {
      return i;
    }
  }
  
  return -1;
}

/// @function char_array_pos_any(array, index, count, chars, safe)
/// @description Returns position of one of the characters from subarray
/// and the appeared character itself within a slice of the given character array
/// @argument {Array<String>} array The array of characters to check in
/// @argument {Real} index The position of the first character in the array to search from
/// @argument {Real} count The number of characters, starting from the position of the first
/// @argument {Array<String>} chars The subarray of characters
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Array<Any>} Returns position of one of the characters from the subarray with the character itself
/// within a slice of the character array
function char_array_pos_any(array, index, count, chars, safe) {
  if (count >= 0) {
    return char_array_pos_any_range(array, index, index + count, chars, safe);
  } else {
    return char_array_pos_any_range(array, index + count + 1, index + 1, chars, safe);
  }
}

/// @function char_array_pos_any_range(array, index, count, chars, safe)
/// @description Returns position of one of the characters from subarray
/// and the appeared character itself within a slice of the given character array
/// @argument {Array<String>} array The array of characters to check in
/// @argument {Real} from The position of the first character in the array
/// @argument {Real} to The position of the last character in the array
/// @argument {Array<String>} chars The subarray of characters
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Array<Any>} Returns position of one of the characters from the subarray with the character itself
/// within a slice of the character array
function char_array_pos_any_range(array, from, to, chars, safe) {
  if (safe) {
    var length = array_length(array);
    from = clamp(from, 0, length - 1);
    to = clamp(to, 1, length);
  }
  
  var sublength = array_length(chars);
  for (var i = from; i < to; i++) {
    for (var j = 0; j < sublength; j++) {
      var c = chars[j];
      if (array[i] == c) {
        return [i, c]
      }
    }
  }
  
  return [-1, ""];
}

/// @function char_array_delete(array, length, index, count)
/// @description Removes a specific part of the given character array
/// @argument {Array<String>} array The array of characters to delete from
/// @argument {Real} index The position of the first character in the array to delete from
/// @argument {Real} count The number of characters, starting from the position of the first
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Array<String>} Returns new array without the specified part in it
function char_array_delete(array, index, count, safe) {
  if (count >= 0) {
    return char_array_delete_range(array, index, index + count, safe);
  } else {
    return char_array_delete_range(array, index + count + 1, index + 1, safe);
  }
}

/// @function char_array_delete_range(array, length, index, count)
/// @description Removes a specific part of the given character array
/// @argument {Array<String>} array The array of characters to delete from
/// @argument {Real} from The position of the first character in the array
/// @argument {Real} to The position of the last character in the array
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Array<String>} Returns new array without the specified part in it
function char_array_delete_range(array, from, to, safe) {
  var length = array_length(array);
    
  if (safe) {
    from = clamp(from, 0, length - 1);
    to = clamp(to, 1, length);
  }
  
  for (var i = to; i < length; i++) {
    array[i + from - to] = array[i];
  }
  
  array_resize(array, length + from - to);
  return array;
}

/// @function char_array_insert(array, index, char, safe)
/// @description Inserts the character in the given position of the character array
/// @argument {Array<String>} array The array of characters to insert to
/// @argument {Real} index The position in the array to insert the character
/// @argument {String} char The character to insert
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Array<String>} Returns new array with inserted character in it
function char_array_insert(array, index, char, safe) {
  var length = array_length(array);
  array_resize(array, length + 1);
    
  if (safe) {
    index = clamp(index, 0, length);
  }
  
  for (var i = length; i > index; i--) {
    array[i] = array[i - 1];
  }
  
  array[index] = char;
  return array;
}

/// function char_array_replace(array, index, count, char, safe)
/// @description Replaces all characters in a specific part of the given character array
/// @argument {Array<String>} array The array of characters in which to replace
/// @argument {Real} index The position of the first character in the array to replace from
/// @argument {Real} count The number of characters, starting from the position of the first
/// @argument {String} char The character to replace with
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Array<String>} Returns new array with specified part filled with the given character
function char_array_replace(array, index, count, char, safe) {
  if (count >= 0) {
    return char_array_replace_range(array, index, index + count, char, safe);
  } else {
    return char_array_replace_range(array, index + count + 1, index + 1, char, safe);
  }
}

/// function char_array_replace_range(array, from, to, char, safe)
/// @description Replaces all characters in a specific part of the given character array
/// @argument {Array<String>} array The array of characters in which to replace
/// @argument {Real} from The position of the first character in the array
/// @argument {Real} to The position of the last character in the array
/// @argument {String} char The character to replace with
/// @argument {Bool} safe When this argument is true, index doesn't leave the character array bounds
/// @returns {Array<String>} Returns new array with the specified part filled with the given character
function char_array_replace_range(array, from, to, char, safe) {
  if (safe) {
    var length = array_length(array);
    from = clamp(from, 0, length - 1);
    to = clamp(to, 1, length);
  }
  
  for (var i = from; i < to; i++) {
    array[i] = char;
  }
  
  return array;
}

/// @function char_array_remove(array, char)
/// @description Removes all occurrences of the given character
/// @argument {Array<String>} array The array of characters to remove the given character from
/// @argument {String} char The character to remove
/// @returns {Array<String>} Returns new array without the given character
function char_array_remove(array, char) {
  var length = array_length(array);
  var removed = 0;
  
  for (var i = 0; i < length; i++) {
    if (array[i] == char) {
      removed++;
    } else {
      array[i - removed] = array[i];
    }
  }
  
  array_resize(array, length - removed);
  return array;
}
