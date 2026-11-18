int far_c(int x) { return x + 1; }

// C calling back into Zig: the thunk side, unchanged.
int zig_twice(int x);
int c_calls_zig(int x) { return zig_twice(x) + 1; }
