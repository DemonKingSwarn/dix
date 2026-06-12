#import "Basic";
#import,file "./module.jai";

main :: () {
  input_path := "./config.dix";  
  dix, ok := load_dix_from_file(input_path);
  if !ok exit(1);

  name := get_dix_value(dix, string, "config", "hero_data", "name").*;
  health := get_dix_value(dix, int, "config", "hero_data", "max_health").*;
  max_oxygen := get_dix_value(dix, float, "config", "hero_data", "max_oxygen").*;
  is_diving := get_dix_value(dix, bool, "config", "hero_data", "is_diving").*;

  print("name: %\nhealth: %\noxygen: %\nis_diving: %\n", name, health, max_oxygen, is_diving);
}


