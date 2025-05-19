const std = @import("std");

pub const MAX_NAME_SIZE = 32;

pub const Color = enum {
    red,
    green,
    reset,
};
const ColorValues = [_][]const u8{
    "\x1b[31m", // red
    "\x1b[32m", // green
    "\x1b[0m", // reset
};

fn getColorValue(c: Color) []const u8 {
    return ColorValues[@intFromEnum(c)];
}

pub fn color_text(allocator: std.mem.Allocator, input_string: []const u8, color: Color) ![]u8 {
    return std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ getColorValue(color), input_string, getColorValue(Color.reset) });
}

pub fn print_message_and_get_response(allocator: std.mem.Allocator, w: anytype, r: anytype, message: []const u8) ![]const u8 {
    try w.print("{s}", .{message});
    return try r.readUntilDelimiterAlloc(allocator, '\n', MAX_NAME_SIZE);
}

pub fn create_and_get_file(path: []const u8, name: []const u8, extension: []const u8) !std.fs.File {
    const allocator = std.heap.page_allocator;
    const jsFilePath = try std.fmt.allocPrint(allocator, "{s}{s}{s}", .{ path, name, extension });
    defer allocator.free(jsFilePath);
    return try std.fs.cwd().createFile(
        jsFilePath,
        .{ .read = true },
    );
}
