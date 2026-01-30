// dirnav.c3 — Directory navigation bookmark tool in modern C3
// import std::io;
// import std::io::path;
// import std::os;
// import std::core::mem;
// import std::core::env;
// import std::core::string;     // Not std::core::string
// import std::core::dstring;  // dstring is in collections, not core

import std::io;
import std::os;
import std::path;          // <-- path is top-level
import std::env;
import std::string;        // <-- string utilities
import std::collections::dstring;
import std::mem;

const int MAX_PATHS = 100;

/* -------------------------------------------------------------------------- */
fn String get_store_file()
{
    String? custom = env::get("DIRNAV_STORE");
    if (custom && custom.len > 0) {
        return path::normalize(custom)!;
    }

    String home;
    String? t = env::get("DIRNAV_HOME");
    if (t && t.len > 0) {
        home = t;
    } else {
        t = env::get("HOME");
        if (t && t.len > 0) {
            home = t;
        } else {
            t = env::get("USERPROFILE");
            if (t && t.len > 0) {
                home = t;
            } else {
                home = os::is_windows() ? "C:\\" : "/tmp";
            }
        }
    }
    return path::join(home, ".dirnav_store");
}

/* -------------------------------------------------------------------------- */
fn void ensure_store_dir(String store_file)
{
    String dir = path::dirname(store_file);
    if (dir.len == 0) dir = ".";
    os::mkdir_recursive(dir);
}

/* -------------------------------------------------------------------------- */
fn int load_paths(String[] out_paths)
{
    String file = get_store_file();
    defer mem::free(file.ptr);

    File? f = io::file::open(file, "r");
    if (!f) {
        return 0; // File doesn't exist yet
    }
    defer io::file::close(f);

    String content = io::file::read_all(f);
    defer mem::free(content.ptr);

    int count = 0;
    String[] lines = string::split(content, "\n");

    for (int i = 0; i < lines.len; i++)
    {
        String line = lines[i];
        if (count == MAX_PATHS) break;
        String trimmed = string::trim(line);
        if (trimmed.len == 0) continue;
        out_paths[count++] = string::copy(trimmed);
    }

    return count;
}

fn void save_paths(String[] store, int count)
{
    String file = get_store_file();
    defer mem::free(file.ptr);
    ensure_store_dir(file);

    DString buf = dstring::new();
    defer dstring::free(buf);

    for (int i = 0; i < count; i++)
    {
        dstring::append(buf, store[i]);
        dstring::append(buf, "\n");
    }

    io::save_file(file, dstring::str_view(buf));
}

/* -------------------------------------------------------------------------- */
fn void add_path(String[] store, int* count, String raw)
{
    if (*count == MAX_PATHS)
    {
        io::printn("⌠Store is full!");
        return;
    }

    if (!os::exists(raw))
        io::printfn("⚠️  Warning: Path doesn't exist: %s", raw);

    String normalized = path::normalize(raw);
    store[*count] = normalized;
    (*count)++;
    save_paths(store, *count);
    io::printfn("✅ Path added: %s", raw);
}

fn void list_paths(String[] store, int count)
{
    if (count == 0)
    {
        io::printn("No paths stored yet.");
        return;
    }
    io::printn("📂 Stored paths:");
    for (int i = 0; i < count; i++)
    {
        io::printfn("[%d] %s", i, store[i]);
    }
}

fn void remove_path(String[] store, int* count, int idx)
{
    if (idx < 0 || idx >= *count)
    {
        io::printn("⌠Invalid index!");
        return;
    }
    io::printfn("🗑️  Removing: %s", store[idx]);
    mem::free(store[idx].ptr);
    for (int i = idx; i < *count - 1; i++) store[i] = store[i + 1];
    (*count)--;
    save_paths(store, *count);
}

fn void navigate(String[] store, int count, int idx)
{
    if (idx < 0 || idx >= count)
    {
        io::eprintn("⌠Invalid index!");
        return;
    }
    io::printn("%s", store[idx]);
}

fn void search_paths(String[] store, int count, String kw)
{
    String kw_lower = string::to_lower(kw);
    defer mem::free(kw_lower.ptr);
    bool found = false;

    for (int i = 0; i < count; i++)
    {
        String path_lower = string::to_lower(store[i]);
        defer mem::free(path_lower.ptr);

        if (string::contains(path_lower, kw_lower))
        {
            io::printfn("[%d] %s", i, store[i]);
            found = true;
        }
    }
    if (!found) io::printfn("🔍 No match found for '%s'", kw);
}

fn void print_help()
{
    io::print(
"Usage: dirnav [command] [options]\n"
"Commands:\n"
"  --add <path>       Add a directory path\n"
"  --list             List stored paths\n"
"  --rm <index>       Remove path at index\n"
"  --nav <index>      Print path at index (use with cd)\n"
"  --search <keyword> Search paths by keyword\n"
"  --help             Show this help message\n\n"
"Environment variables:\n"
"  DIRNAV_STORE       Custom store file location\n"
"  DIRNAV_HOME        Custom home directory\n");
}

/* -------------------------------------------------------------------------- */
fn int main()
{
    String[MAX_PATHS] store = {0};
    int count = load_paths(store);

    // Clean up loaded strings on exit
    defer {
        for (int i = 0; i < count; i++) {
            mem::free(store[i].ptr);
        }
    }

    int argc = os::argc;
    char** argv = os::argv;

    if (argc < 2)
    {
        print_help();
        return 0;
    }

    String cmd = string::from_cstr(argv[1]);

    if (string::eq(cmd, "--help"))
    {
        print_help();
    }
    else if (string::eq(cmd, "--add"))
    {
        if (argc < 3) {
            io::printn("⌠Missing path");
        } else {
            String raw = string::from_cstr(argv[2]);
            add_path(store, &count, raw);
        }
    }
    else if (string::eq(cmd, "--list"))
    {
        list_paths(store, count);
    }
    else if (string::eq(cmd, "--rm"))
    {
        if (argc < 3) {
            io::printn("⌠Missing index");
        } else {
            int idx = string::to_int(string::from_cstr(argv[2]));
            remove_path(store, &count, idx);
        }
    }
    else if (string::eq(cmd, "--nav"))
    {
        if (argc < 3) {
            io::printn("⌠Missing index");
        } else {
            int idx = string::to_int(string::from_cstr(argv[2]));
            navigate(store, count, idx);
        }
    }
    else if (string::eq(cmd, "--search"))
    {
        if (argc < 3) {
            io::printn("⌠Missing keyword");
        } else {
            String kw = string::from_cstr(argv[2]);
            search_paths(store, count, kw);
        }
    }
    else
    {
        io::printn("⌠Unknown command");
        print_help();
    }

    return 0;
}
