#if OS == .LINUX || OS == .MACOS {
  #load "linux.jai";
} else #if OS == .WINDOWS {
  #load "windows.jai";
}
