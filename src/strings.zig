const std = @import("std");
const ServerStrings = struct { init: []const u8, method: []const u8 };

const php_file_template_string = @embedFile("./templates/php.zphp");

pub fn get_php_file_string(allocator: std.mem.Allocator, namespace: []const u8, module_name: []const u8, server: bool) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    const w = list.writer();

    const server_strings = s_string: {
        if (!server) {
            break :s_string ServerStrings{ .init = "", .method = "" };
        } else {
            break :s_string ServerStrings{ .init = "$this->nodeClient->requestNodeData($this, $this->params);", .method = 
            \\
            \\    public function setNodeResponse (array $nodeResponse) {
            \\        $this->renderData = $nodeResponse;
            \\    }
            \\
        };
        }
    };

    try w.print(php_file_template_string, .{ namespace, module_name, module_name, server_strings.init, server_strings.method });

    return list.toOwnedSlice();
}
