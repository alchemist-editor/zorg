const std = @import("std");

// Each needs compiler_rt on aarch64: f128 arithmetic, 128-bit division, conversions.
var a: f128 = 1.5;
var n: u128 = 1 << 100;
var d: u128 = 3;
var f: f64 = 1e30;

test "f128 arithmetic" {
    a = a * 3 + 0.25;
    try std.testing.expectEqual(@as(f128, 4.75), a);
}

test "128-bit division and remainder" {
    try std.testing.expectEqual(@as(u128, 422550200076076467165567735125), n / d);
    try std.testing.expectEqual(@as(u128, 1), n % d);
}

test "float and 128-bit integer conversions" {
    const i: u128 = @intFromFloat(f);
    try std.testing.expectEqual(f, @as(f64, @floatFromInt(i)));
}
