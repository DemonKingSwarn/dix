#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Bindings_Generator";

dir: string;
file: string;
lib: string;

#run {
  set_build_options_dc(.{do_output = false});
  
  #if OS == .LINUX {
    dir = "linux";
    file = "linux.jai";
  } else #if OS == .MACOS {
    dir = "macos";
    file = "macos.jai";
  } else #if OS == .WINDOWS {
    dir = "windows";
    file = "windows.jai";
  }

  if !build_cpp(tprint("libs/%/stb_c_lexer", dir), "stb_c_lexer.h", type = .STATIC_LIBRARY, debug = true, extra = .["-x", "c", "-DSTB_C_LEXER_IMPLEMENTATION"]) exit(1);
  if !build_cpp(tprint("libs/%/stb_c_lexer", dir), "stb_c_lexer.h", type = .DYNAMIC_LIBRARY, debug = true, extra = .["-x", "c", "-DSTB_C_LEXER_IMPLEMENTATION"]) exit(1);
  
  options: Generate_Bindings_Options;
  array_add(*options.libraries, .{ filename = tprint("libs/%/stb_c_lexer", dir), identifier = "stb_c_lexer" });
  array_add(*options.source_files, "stb_c_lexer.h");

  if !generate_bindings(options, file) then exit(1);
}
