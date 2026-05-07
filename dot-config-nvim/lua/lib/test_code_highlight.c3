
// Demonstration of (almost) all C3 keywords in one file

module demo;
import io;
using namespace io;

typedef i32 MyInt;

struct Point {
    i32 x;
    i32 y;
};

union Value {
    i32 i;
    f64 f;
    bool b;
};

enum Color {
    Red,
    Green,
    Blue,
    Default
};

const static i32 CONST_VAL = 42;

fn inline add(i32 a, i32 b) -> i32 {
    return a + b;
}

fn extern panic_fn() {
    panic("Something went wrong!");
}

fn test keyword_test() {
    let auto num = 10;
    let bool flag = true;
    let string msg = "Hello C3!";
    let f32 pi = 3.14f;

    // Control flow
    if flag {
        io::print(msg);
    } else {
        io::print("false branch");
    }

    switch num {
        case 1: io::print("one"); break;
        case 2: io::print("two"); break;
        default: io::print("other"); break;
    }

    for i32 i = 0; i < 5; i++ {
        continue;
    }

    foreach p in [1,2,3] {
        io::print("foreach loop");
    }

    while num > 0 {
        num--;
    }

    do {
        num++;
    } while num < 3;

    try {
        throw "error!";
    } catch {
        io::print("caught exception");
    }

    // Memory ops
    let Point* p = new Point;
    delete p;

    let sz = sizeof(Point);
    let al = alignof(Point);
    let tp = typeof(num);

    // Operators
    let i32 op = (1 + 2) * 3 / 4 % 5;
    let bool cmp = (op == 2) && (op != 3) || (op < 10);

    // Attributes
    @inline fn attr_fn() -> void { return; }
    @packed struct Packed { i8 a; i8 b; }
    @align(16) struct Aligned { i32 a; }
    @deprecated fn old_fn() {}
    @extern fn ext_fn() {}
}

fn main() {
    keyword_test();
}
