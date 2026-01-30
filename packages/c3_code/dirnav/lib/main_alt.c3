module main;

import std::io;
import std::core::mem::allocator;
import array;

fn int main()
{
    Allocator* alloc = allocator::heap();

    Array(int) numbers;
    array::init(&numbers, alloc);

    array::push(&numbers, 10);
    array::push(&numbers, 20);
    array::push(&numbers, 30);

    io::println("Array contents:");

    ArrayIterator(int) it = array::iter(&numbers);
    while (true)
    {
        int* v = array::next(&it);
        if (v == null) break;
        io::println(*v);
    }

    array::deinit(&numbers);

    return 0;
}
