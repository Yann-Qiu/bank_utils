if [[ "$1" != "" ]]; then
  flutter run -d macos --dart-define=target=$1
else 
  flutter run -d macos
fi