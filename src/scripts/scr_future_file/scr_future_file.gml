//! Wrapper functions for file handling tasks.

//# feather use syntax-errors

/// The default title used for game saves.
#macro FUTURE_FILE_TITLE "Save File"

/// Loads a buffer asynchronously and returns a new [Future]. This future is
/// accepted if the file was loaded successfully; or rejected if there was a
/// problem, such as the file not existing.
///
/// @param {String} group
///   The name of the group to match.
///
/// @param {String} path
///   The path of the file to read.
///
/// @param {String} [title]
///   The title used to identify this file. Defaults to "Save File".
///
/// @return {Struct.Future}
function future_file_read(group, path, title=FUTURE_FILE_TITLE) {
    var filename = filename_change_ext(filename_name(path), "");
    var future = new Future();
    if (os_browser == browser_not_a_browser) {
        with (instance_create_depth(0, 0, 0, obj_future_file_load)) {
            self.future = future;
            buffer_async_group_begin(group);
            buffer_async_group_option("showdialog", false);
            buffer_async_group_option("slottitle", title);
            buffer_async_group_option("subtitle", filename);
            buffer_load_async(self.buffer, path, 0, -1);
            idx = buffer_async_group_end();
        }
    } else {
        // temporary fix due to encoding issues on HTML5
        var buffer = buffer_load(group + "/" + path);
        if (buffer != -1) {
            // it is the responsibility of the user to delete the buffer
            future.accept(buffer);
        } else {
            future.reject();
            buffer_delete(buffer);
        }
    }
    return future;
}

/// Similar to [future_file_read], except the result is converted into a
/// string value.
///
/// @param {String} group
///   The name of the group to match.
///
/// @param {String} path
///   The path of the file to read.
///
/// @param {String} [title]
///   The title used to identify this file. Defaults to "Save File".
///
/// @return {Struct.Future}
function future_file_read_string(group, path, title) {
    var future = future_file_read(group, path, title);
    return future.andThen(function(buffer) {
        var content = buffer_read(buffer, buffer_string);
        buffer_delete(buffer);
        return content;
    });
}

/// Saves a buffer asynchronously and returns a new [Future]. This future is
/// accepted if the file was saved successfully; or rejected if there was a
/// problem saving the file.
///
/// @param {String} group
///   The name of the group to match.
///
/// @param {String} path
///   The path of the file to write to.
///
/// @param {Id.Buffer} buffer
///   The ID of the buffer to write.
///
/// @param {String} [title]
///   The title used to identify this file. Defaults to "Save File".
///
/// @return {Struct.Future}
function future_file_write(group, path, buffer, title=FUTURE_FILE_TITLE) {
    var filename = filename_change_ext(filename_name(path), "");
    var future = new Future();
    with (instance_create_depth(0, 0, 0, obj_future_file_save)) {
        self.future = future;
        var size = buffer_get_size(buffer);
        buffer_copy(buffer, 0, size, self.buffer, 0);
        if (os_browser == browser_not_a_browser) {
            buffer_async_group_begin(group);
            buffer_async_group_option("showdialog", false);
            buffer_async_group_option("slottitle", title);
            buffer_async_group_option("subtitle", filename);
            buffer_save_async(self.buffer, path, 0, size);
            idx = buffer_async_group_end();
        } else {
            idx = buffer_save_async(self.buffer, group + "/" + path, 0, size);
        }
    }
    return future;
}

/// Similar to [future_file_write], except the input is converted into a string
/// buffer before being written to the destination.
///
/// @param {String} group
///   The name of the group to match.
///
/// @param {String} path
///   The path of the file to read.
///
/// @param {Any} value
///   The value to write to the file. Implicitly converted into a string.
///
/// @param {String} [title]
///   The title used to identify this file. Defaults to "Save File".
///
/// @return {Struct.Future}
function future_file_write_string(group, path, value, title) {
    var buffer = buffer_create(1, buffer_grow, 1);
    buffer_write(buffer, buffer_string,
            is_string(value) ? value : string(value));
    var future = future_file_write(group, path, buffer, title);
    buffer_delete(buffer);
    return future;
}