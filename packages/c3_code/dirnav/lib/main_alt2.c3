module compare_exe;

import std::io;
import std::core::string;
import std::core::mem;         // Added for heap_allocator()
import std::collections::list;
import libc;

// C bindings
extern fn void* popen(ZString command, ZString mode) @extern("popen");
extern fn int pclose(void* stream) @extern("pclose");
extern fn char* fgets(char* str, int size, void* stream) @extern("fgets");

extern fn void* fopen(ZString filename, ZString mode) @extern("fopen");
extern fn int fclose(void* stream) @extern("fclose");
extern fn int fseek(void* stream, long offset, int whence) @extern("fseek");
extern fn long ftell(void* stream) @extern("ftell");

const int SEEK_END = 2;

// -------------------------------
// Data
// -------------------------------

struct BinaryInfo
{
    String filename;
    String label;
    long size;
    List{String} ldd_lines;
}

// -------------------------------
// Helpers
// -------------------------------

fn String human_readable_size(long bytes)
{
    if (bytes < 0) return "Error";

    const String[4] SIZE_UNITS = { "bytes", "KB", "MB", "GB" };
    int u = 0;
    double val = (double)bytes;

    while (val >= 1024.0 && u < 3)
    {
        val /= 1024.0;
        u++;
    }

    if (u == 0)
    {
        return string::tformat("%d %s", bytes, SIZE_UNITS[u]);
    }
    else
    {
        return string::tformat("%.2f %s", val, SIZE_UNITS[u]);
    }
}

fn List{String} get_ldd_output(String filename)
{
    String cmd = string::tformat("ldd \"%s\" 2>&1", filename);
    void* pipe = popen((ZString)cmd, "r");

    List{String} lines;
    lines.init(mem);  // Fixed: use 'mem' (global heap allocator)

    if (pipe == null)
    {
        lines.push("ldd: popen failed");
        return lines;
    }

    defer pclose(pipe);

    char[1024] buffer;
    while (true)
    {
        char* result = fgets(&buffer[0], buffer.len, pipe);
        if (result == null) break;

        usz len = 0;
        while (len < buffer.len && buffer[len] != '\0')
        {
            len++;
        }

        while (len > 0 && (buffer[len - 1] == '\n' || buffer[len - 1] == '\r'))
        {
            len--;
        }

        if (len > 0)
        {
            String line = (String)buffer[0..len];
            lines.push(line);
        }
    }

    if (lines.len() == 0)
    {
        lines.push("N/A");
    }

    return lines;
}

fn long get_file_size(String filename)
{
    void* f = fopen((ZString)filename, "rb");
    if (f == null) return -1;

    defer fclose(f);

    if (fseek(f, 0, SEEK_END) != 0) return -1;
    long sz = ftell(f);
    return sz < 0 ? -1 : sz;
}

fn void print_separator(int[] widths)
{
    io::print("+");
    foreach (w : widths)
    {
        for (int i = 0; i < w + 2; i++)
        {
            io::print("-");
        }
        io::print("+");
    }
    io::printn();
}

fn void print_cell(String text, int width)
{
    io::print(" ");
    io::print(text);
    int padding = width - (int)text.len;
    for (int i = 0; i < padding; i++)
    {
        io::print(" ");
    }
    io::print(" |");
}

// -------------------------------
// Main
// -------------------------------

fn int main(String[] args)
{
    if (args.len < 3 || ((args.len - 1) % 2) != 0)
    {
        io::eprintfn("Usage: %s <binary1> \"<label1>\" <binary2> \"<label2>\" ...", args[0]);
        return 1;
    }

    List{BinaryInfo} binaries;
    binaries.init(mem);  // Same here for consistency

    int count = (args.len - 1) / 2;
    for (int i = 0; i < count; i++)
    {
        BinaryInfo info;
        info.filename = args[1 + i * 2];
        info.label = args[2 + i * 2];
        info.size = get_file_size(info.filename);
        info.ldd_lines = get_ldd_output(info.filename);
        binaries.push(info);
    }

    String[5] headers = {
        "File", "Label", "Size (bytes)", "Size (human)", "LDD Output"
    };
    int[5] widths = {20, 15, 12, 14, 50};

    // Adjust widths
    foreach (i, b : binaries)
    {
        widths[0] = max(widths[0], (int)b.filename.len);
        widths[1] = max(widths[1], (int)b.label.len);

        String size_str;
        if (b.size >= 0)
        {
            size_str = string::tformat("%d", b.size);
        }
        else
        {
            size_str = "Error";
        }
        widths[2] = max(widths[2], (int)size_str.len);

        foreach (j, line : b.ldd_lines)
        {
            widths[4] = max(widths[4], (int)line.len);
        }
    }

    // Header
    print_separator(&widths);
    io::print("|");
    for (int i = 0; i < headers.len; i++)
    {
        print_cell(headers[i], widths[i]);
    }
    io::printn();
    print_separator(&widths);

    // Rows
    foreach (i, b : binaries)
    {
        String size_str;
        String human;

        if (b.size >= 0)
        {
            size_str = string::tformat("%d", b.size);
            human = human_readable_size(b.size);
        }
        else
        {
            size_str = "Error";
            human = "N/A";
        }

        String first_line = "";
        if (b.ldd_lines.len() > 0)
        {
            first_line = b.ldd_lines.get(0);
        }

        io::print("|");
        print_cell(b.filename, widths[0]);
        print_cell(b.label, widths[1]);
        print_cell(size_str, widths[2]);
        print_cell(human, widths[3]);
        print_cell(first_line, widths[4]);
        io::printn();

        for (usz j = 1; j < b.ldd_lines.len(); j++)
        {
            io::print("|");
            for (int c = 0; c < 4; c++)
            {
                print_cell("", widths[c]);
            }
            print_cell(b.ldd_lines.get(j), widths[4]);
            io::printn();
        }

        print_separator(&widths);
    }

    return 0;
}
