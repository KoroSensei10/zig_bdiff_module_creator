const std = @import("std");
const ServerStrings = struct { init: []const u8, method: []const u8 };

const php_file_template_string = @embedFile("./templates/php.zphp");
const jsC_file_template_string = @embedFile("./templates/js_client.zjs");
const jsS_file_template_string = @embedFile("./templates/js_server.zjs");

const services_template_string =
    \\    blg.module.ecommerce.{s}:
    \\        class: Blg\ModuleBundle\{s}\{s}\{s}
    \\        arguments: [ '@kernel', '@templating', '@blg_api.api_curl_client', '@blg_node.node_client', '@translator', '@router' ]
    \\        shared: false
    \\        public: true
    \\
;

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

pub fn get_jsC_file_string(allocator: std.mem.Allocator, module_name: []const u8) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    const w = list.writer();

    try w.print(jsC_file_template_string, .{ module_name, module_name });

    return list.toOwnedSlice();
}

pub fn get_jsS_file_string(allocator: std.mem.Allocator, module_name: []const u8) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    const w = list.writer();

    try w.print(jsS_file_template_string, .{ module_name, module_name });

    return list.toOwnedSlice();
}

pub fn get_twig_string() ![]const u8 {
    return 
    \\<div id="{{ this.domId }}" class="{{ this.getHtmlClassStr }}">
    \\    
    \\</div>
    ;
}

pub fn get_less_string(allocator: std.mem.Allocator, module_name: []const u8, namespace: []const u8) ![]const u8 {
    var list = std.ArrayList(u8).init(allocator);
    defer list.deinit();

    const w = list.writer();

    const less_string =
        \\.blgMod{s}{s} {{
        \\
        \\}}
    ;

    try w.print(less_string, .{ namespace, module_name });

    return list.toOwnedSlice();
}
