#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Bindings_Generator";

#run {
  set_build_options_dc(.{do_output = false});
  ok := build_cpp("stb_c_lexer", "stb_c_lexer.h", type = .STATIC_LIBRARY, debug = true, extra = .["-x", "c", "-DSTB_C_LEXER_IMPLEMENTATION"]);
  ok = build_cpp("stb_c_lexer", "stb_c_lexer.h", type = .DYNAMIC_LIBRARY, debug = true, extra = .["-x", "c", "-DSTB_C_LEXER_IMPLEMENTATION"]);
  
  options: Generate_Bindings_Options;
  array_add(*options.libraries, .{ filename = "stb_c_lexer" });
  array_add(*options.source_files, "stb_c_lexer.h");

  if !generate_bindings(options, "module.jai") then exit(1);
}
