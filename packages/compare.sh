
EXECUTOR="./c_code/compare_exe.exe"

echo "### dirnav"
"$EXECUTOR" ./c_code/dirnav.exe "C99" ./czig_code/_bin/dirnav.exe "ZIG" ./crust_code/_bin/release/dirnav.exe "RUST"
