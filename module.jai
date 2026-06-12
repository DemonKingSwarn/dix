DIX :: Any;  

Object :: Table(string, Any);

get_dix_value :: (dix: DIX, $T: Type, path: ..string) -> *T {
  cursor := dix; 
  for key: path {
    if cursor.type != cast(*Type_Info)Object return null;
    object := cast(*Object)cursor.value_pointer;
    ok, next_cursor := table_find(object, key);
    if !ok return null;
    cursor = next_cursor;
  }

  if cursor.type != cast(*Type_Info)T return null;
  return cursor.value_pointer;
}

load_dix_from_file :: (file_path: string) -> (dix: DIX, ok: bool) {
  content, ok := read_entire_file(file_path); 
  if !ok return null, false;
  
  l: stb_lexer;

  string_store: [1024]u8;

  stb_c_lexer_init(*l, content.data, content.data + content.count, string_store.data, string_store.count);

  value := New(Object);
  if !parse_object_body(file_path, *l, value) return null, false;
  return Any.{cast(*Type_Info)Object, value}, true;

}

dump_value :: (root: Any, level := 0) {
  if root.type.type == {
    case .FLOAT; #through;
    case .INTEGER; #through;
    case .STRING; print("\"%\"", root);
    case .BOOL; print("%", root);
    case .STRUCT;
      if root.type == cast(*Type_Info)Object {
        object : *Object = root.value_pointer; 
        print("{\n");
        for object {
          for 1..level+1 print("  "); print("% => ", it_index); 
          dump_value(it, level + 1);
          print(",\n");
        }
        for 1..level print("  "); print("}");
      } else {
        assert(false, "unreachable");
      }
    case; assert(false, "unreachable");
  }
}


#scope_file

expect_tokens :: (file_path: string, l: *stb_lexer, expected_tokens: s64) -> (ok: bool) {
  stb_c_lexer_get_token(l);
  if l.token != expected_tokens {
    report_error(file_path, l, "ERROR: Unexpected token. Expected % but got %", expected_tokens, l.token);
    return false;
  }

  return true;
}

report_error :: (file_path: string, l: *stb_lexer, format_string: string, args: .. Any) {
  loc: stb_lex_location;
  stb_c_lexer_get_location(l, l.where_firstchar, *loc);
  print("%:%:%\n", file_path, loc.line_number, loc.line_offset);
  print(format_string, ..args);
  print("\n");
}

parse_value :: (file_path: string, l: *stb_lexer) -> value: Any, ok: bool {
  stb_c_lexer_get_token(l);
  if l.token == {
    case #char "{";
      value := New(Object);
      if !parse_object_body(file_path, l, value) return null, false;
      // We expect parse_object_body to consume `}` for us
      return Any.{cast(*Type_Info)Object, value}, true;

    case xx CLEX.floatlit;
      value := New(float);
      value.* = xx l.real_number;
      return Any.{cast(*Type_Info)float, value}, true;

    case xx CLEX.intlit;
      value := New(int);
      value.* = xx l.int_number;
      return Any.{cast(*Type_Info)int, value}, true;

    case xx CLEX.id;
      id := copy_string(to_string(l._string));
      if id == {
        case "true";
          value := New(bool);
          value.* = true;
          return Any.{cast(*Type_Info)bool, value}, true;
        case "false";
          value := New(bool);
          value.* = false;
          return Any.{cast(*Type_Info)bool, value}, true;
        case;
          report_error(file_path, l, "ERROR: Unexpected identifier %", id);
          return null, false;
      }

    case xx CLEX.dqstring;
      value := New(string);
      value.* = copy_string(to_string(l._string));
      return Any.{cast(*Type_Info)string, value}, true;

    case;
      report_error(file_path, l, "ERROR: Unexpected token %\n", l.token);
      return null, false;
   }

  assert(false, "unreachable");
  return null, false;
}

parse_object_body :: (file_path: string, l: *stb_lexer, object: *Object) -> (ok: bool) {
  while true { 
    saved_l := l.*;
    stb_c_lexer_get_token(l);;
    if l.token == #char "}" || l.token == xx CLEX.eof return true;
    l.* = saved_l;

    if !expect_tokens(file_path, l, xx CLEX.id) return false;
    key := copy_string(to_string(l._string));
    if table_contains(object, key) {
      report_error(file_path, l, "ERROR: Redefinition of field %", key); 
      return false;
    }
    if !expect_tokens(file_path, l, #char "=") return false;
    value, ok := parse_value(file_path, l);
    if !ok return false;
    if !expect_tokens(file_path, l, #char ";") return false;
    table_add(object, key, value);
  }

  assert(false, "TODO");
  return false;
}

#import,file "stb_c_lexer/module.jai";
#import "Basic";
#import "File";
#import "Hash_Table";
