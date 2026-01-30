module array;

import std::core::mem::allocator;

/* =========================
   Generic Dynamic Array using C3 macros
   ========================= */

macro void define_array($t: type)
{
    struct Array($t)
    {
        $t* data;
        usz len;
        usz cap;
        Allocator* alloc;
    }

    fn void init(Array($t)* self, Allocator* alloc)
    {
        self.data = null;
        self.len = 0;
        self.cap = 0;
        self.alloc = alloc;
    }

    fn void deinit(Array($t)* self)
    {
        if (self.data != null)
        {
            self.alloc.free(self.data);
            self.data = null;
            self.len = 0;
            self.cap = 0;
        }
    }

    fn void reserve(Array($t)* self, usz new_cap)
    {
        if (new_cap <= self.cap) return;

        $t* new_data = ($t*)self.alloc.realloc(
            self.data,
            self.cap * sizeof($t),
            new_cap * sizeof($t)
        );

        self.data = new_data;
        self.cap = new_cap;
    }

    fn void push(Array($t)* self, $t value)
    {
        if (self.len == self.cap)
        {
            usz new_cap = self.cap == 0 ? 8 : self.cap * 2;
            self.reserve(new_cap);
        }

        self.data[self.len] = value;
        self.len += 1;
    }

    fn $t* get(Array($t)* self, usz index)
    {
        if (index >= self.len) return null;
        return &self.data[index];
    }

    /* Iterator */
    struct ArrayIterator($t)
    {
        Array($t)* array;
        usz index;
    }

    fn ArrayIterator($t) iter(Array($t)* array)
    {
        ArrayIterator($t) it = { .array = array, .index = 0 };
        return it;
    }

    fn $t* next(ArrayIterator($t)* self)
    {
        if (self.index >= self.array.len)
            return null;

        $t* value = &self.array.data[self.index];
        self.index += 1;
        return value;
    }
}

// Instantiate for int (add more types as needed, e.g. define_array(float);)
define_array(int);
