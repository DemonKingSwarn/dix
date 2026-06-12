#import "Basic";
#import,file "./module.jai";

main :: () {
  input_path := "./config.dix";  
  dix, ok := load_dix_from_file(input_path);
  if !ok exit(1);

  print("%\n", get_dix_value(dix, string, "config", "hero_data", "name").*);

}


