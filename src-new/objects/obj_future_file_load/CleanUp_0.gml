/// @desc Clean-up resources.

//# feather use syntax-errors

if (deleteBuffer && buffer_exists(buffer)) {
    buffer_delete(buffer);
}

if (!future.resolved()) {
    future.reject("failed to read file");
}