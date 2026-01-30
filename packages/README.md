
# cli comparison

```bash
+---------------------------------------+-----------------+--------------+--------------+----------------------------------------------------------------------------+
| File                                  | Label           | Size (bytes) | Size (human) | LDD Output                                                                 |
+---------------------------------------+-----------------+--------------+--------------+----------------------------------------------------------------------------+
| ./dirnav.exe                          | C               | 279722       | 273.17 KB    |       ntdll.dll => /c/WINDOWS/SYSTEM32/ntdll.dll (0x7ffeb6da0000)               |
|                                       |                 |              |              |       KERNEL32.DLL => /c/WINDOWS/System32/KERNEL32.DLL (0x7ffeb5f90000)         |
|                                       |                 |              |              |       KERNELBASE.dll => /c/WINDOWS/System32/KERNELBASE.dll (0x7ffeb40b0000)     |
|                                       |                 |              |              |       msvcrt.dll => /c/WINDOWS/System32/msvcrt.dll (0x7ffeb5d80000)             |
+---------------------------------------+-----------------+--------------+--------------+----------------------------------------------------------------------------+
| ../czig_code/_bin/dirnav.exe          | ZIG             | 545792       | 533.00 KB    |       ntdll.dll => /c/WINDOWS/SYSTEM32/ntdll.dll (0x7ffeb6da0000)               |
|                                       |                 |              |              |       KERNEL32.DLL => /c/WINDOWS/System32/KERNEL32.DLL (0x7ffeb5f90000)         |
|                                       |                 |              |              |       KERNELBASE.dll => /c/WINDOWS/System32/KERNELBASE.dll (0x7ffeb40b0000)     |
+---------------------------------------+-----------------+--------------+--------------+----------------------------------------------------------------------------+
| ../crust_code/_bin/release/dirnav.exe | RUST            | 348672       | 340.50 KB    |       ntdll.dll => /c/WINDOWS/SYSTEM32/ntdll.dll (0x7ffeb6da0000)               |
|                                       |                 |              |              |       KERNEL32.DLL => /c/WINDOWS/System32/KERNEL32.DLL (0x7ffeb5f90000)         |
|                                       |                 |              |              |       KERNELBASE.dll => /c/WINDOWS/System32/KERNELBASE.dll (0x7ffeb40b0000)     |
|                                       |                 |              |              |       shell32.dll => /c/WINDOWS/System32/shell32.dll (0x7ffeb5530000)           |
|                                       |                 |              |              |       msvcp_win.dll => /c/WINDOWS/System32/msvcp_win.dll (0x7ffeb4840000)       |
|                                       |                 |              |              |       ucrtbase.dll => /c/WINDOWS/System32/ucrtbase.dll (0x7ffeb46f0000)         |
|                                       |                 |              |              |       USER32.dll => /c/WINDOWS/System32/USER32.dll (0x7ffeb4bd0000)             |
|                                       |                 |              |              |       win32u.dll => /c/WINDOWS/System32/win32u.dll (0x7ffeb48f0000)             |
|                                       |                 |              |              |       GDI32.dll => /c/WINDOWS/System32/GDI32.dll (0x7ffeb4fd0000)               |
|                                       |                 |              |              |       gdi32full.dll => /c/WINDOWS/System32/gdi32full.dll (0x7ffeb45b0000)       |
|                                       |                 |              |              |       wintypes.dll => /c/WINDOWS/System32/wintypes.dll (0x7ffeb49e0000)         |
|                                       |                 |              |              |       combase.dll => /c/WINDOWS/System32/combase.dll (0x7ffeb69d0000)           |
|                                       |                 |              |              |       RPCRT4.dll => /c/WINDOWS/System32/RPCRT4.dll (0x7ffeb5c60000)             |
|                                       |                 |              |              |       VCRUNTIME140.dll => /c/WINDOWS/SYSTEM32/VCRUNTIME140.dll (0x7ffe6cea0000) |
+---------------------------------------+-----------------+--------------+--------------+----------------------------------------------------------------------------+
```
