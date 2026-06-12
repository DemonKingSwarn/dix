#import "Basic";
#import,file "./module.jai";

main :: () {
  input_path := "./config.dix";  
  dix, ok := load_dix_from_file(input_path);
  if !ok exit(1);

  name : string = get_dix_value(dix, string, "config", "hero_data", "name").*;
  health : int = get_dix_value(dix, int, "config", "hero_data", "max_health").*;
  max_oxygen : float = get_dix_value(dix, float, "config", "hero_data", "max_oxygen").*;

  print("name: %\nhealth: %\noxygen: %\n", name, health, max_oxygen);

}


