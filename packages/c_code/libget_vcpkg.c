#define _CRT_SECURE_NO_WARNINGS
#include <direct.h>
#include <stdio.h>
#include <windows.h>

int run_process(const wchar_t *cmd) {
  STARTUPINFOW si = {sizeof(si)};
  PROCESS_INFORMATION pi;

  if (!CreateProcessW(NULL, (LPWSTR)cmd, NULL, NULL, FALSE, 0, NULL, NULL, &si,
                      &pi)) {
    wprintf(L"Cannot run command: %s\n", cmd);
    return 1;
  }

  WaitForSingleObject(pi.hProcess, INFINITE);

  DWORD ec;
  GetExitCodeProcess(pi.hProcess, &ec);
  CloseHandle(pi.hProcess);
  CloseHandle(pi.hThread);
  return ec;
}

void copy_recursive(const wchar_t *src, const wchar_t *dst) {
  WIN32_FIND_DATAW fd;
  wchar_t srcp[MAX_PATH], dstp[MAX_PATH];

  wsprintfW(srcp, L"%s\\*", src);
  HANDLE h = FindFirstFileW(srcp, &fd);
  if (h == INVALID_HANDLE_VALUE)
    return;

  CreateDirectoryW(dst, NULL);

  do {
    if (!wcscmp(fd.cFileName, L".") || !wcscmp(fd.cFileName, L".."))
      continue;

    wsprintfW(srcp, L"%s\\%s", src, fd.cFileName);
    wsprintfW(dstp, L"%s\\%s", dst, fd.cFileName);

    if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
      CreateDirectoryW(dstp, NULL);
      copy_recursive(srcp, dstp);
    } else {
      CreateDirectoryW(dst, NULL);
      CopyFileW(srcp, dstp, FALSE);
    }
  } while (FindNextFileW(h, &fd));

  FindClose(h);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    printf("Usage:\n");
    printf("  libget_vcpkg <package> [-o <output_dir>]\n");
    return 1;
  }

  //
  // 1. Read package name
  //
  wchar_t pkg[128];
  mbstowcs(pkg, argv[1], 128);

  //
  // 2. Parse arguments for -o / --output
  //
  wchar_t outputBase[MAX_PATH] = L"";

  for (int i = 2; i < argc; i++) {
    if ((strcmp(argv[i], "-o") == 0 || strcmp(argv[i], "--output") == 0) &&
        i + 1 < argc) {
      mbstowcs(outputBase, argv[i + 1], MAX_PATH);
      i++;
    }
  }

  //
  // 3. Default output = <cwd>\vendor
  //
  if (wcslen(outputBase) == 0) {
    wchar_t cwd[MAX_PATH];
    _wgetcwd(cwd, MAX_PATH);
    wsprintfW(outputBase, L"%s\\vendor", cwd);
  }

  //
  // 4. Run: vcpkg install <pkg>
  //
  wchar_t cmd[256];
  wsprintfW(cmd, L"vcpkg install %s", pkg);
  wprintf(L"Running: %s\n", cmd);

  if (run_process(cmd) != 0) {
    wprintf(L"Installation failed.\n");
    return 1;
  }

  //
  // 5. Resolve VCPKG_ROOT
  //
  wchar_t vroot[MAX_PATH];
  if (!GetEnvironmentVariableW(L"VCPKG_ROOT", vroot, MAX_PATH)) {
    wprintf(L"VCPKG_ROOT must be defined.\n");
    return 1;
  }

  wchar_t tripletPath[MAX_PATH];
  wsprintfW(tripletPath, L"%s\\installed\\x64-windows", vroot);

  //
  // 6. Metadata folder for package
  //
  wchar_t metaDir[MAX_PATH];
  wsprintfW(metaDir, L"%s\\share\\%s", tripletPath, pkg);

  DWORD attr = GetFileAttributesW(metaDir);
  if (attr == INVALID_FILE_ATTRIBUTES) {
    wprintf(L"No metadata for package.\n");
    return 1;
  }

  //
  // 7. Output folder = <outputBase>/<pkg>
  //
  wchar_t pkgOut[MAX_PATH];
  wsprintfW(pkgOut, L"%s\\%s", outputBase, pkg);
  CreateDirectoryW(outputBase, NULL);
  CreateDirectoryW(pkgOut, NULL);

  //
  // Copy include/
  //
  wchar_t srcInc[MAX_PATH], dstInc[MAX_PATH];
  wsprintfW(srcInc, L"%s\\include", tripletPath);
  wsprintfW(dstInc, L"%s\\include", pkgOut);
  copy_recursive(srcInc, dstInc);

  //
  // Copy lib/
  //
  wchar_t srcLib[MAX_PATH], dstLib[MAX_PATH];
  wsprintfW(srcLib, L"%s\\lib", tripletPath);
  wsprintfW(dstLib, L"%s\\lib", pkgOut);
  copy_recursive(srcLib, dstLib);

  //
  // Copy bin/
  //
  wchar_t srcBin[MAX_PATH], dstBin[MAX_PATH];
  wsprintfW(srcBin, L"%s\\bin", tripletPath);
  wsprintfW(dstBin, L"%s\\bin", pkgOut);
  copy_recursive(srcBin, dstBin);

  //
  // Copy share/<pkg>
  //
  wchar_t dstShare[MAX_PATH];
  wsprintfW(dstShare, L"%s\\share", pkgOut);
  copy_recursive(metaDir, dstShare);

  wprintf(L"Package extracted into: %s\n", pkgOut);
  return 0;
}
