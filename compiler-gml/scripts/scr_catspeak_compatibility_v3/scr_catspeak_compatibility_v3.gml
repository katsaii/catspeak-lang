//! Contains a simple compatibility layer for help with converting projects
//! from Catspeak 3 to Catspeak 4.

//# feather use syntax-errors

// CATSPEAK 3 //

/// Determines whether sanity checks and unsafe developer features are enabled
/// at runtime.
///
/// @deprecated {4.0.0}
///   Debug info is embedded by default now.
///
/// Debug mode is enabled by default, but you can disable these checks by
/// defining a configuration macro, and setting it to `false`:
/// ```gml
/// #macro Release:CATSPEAK_DEBUG_MODE false
/// ```
///
/// @warning
///   Although disabling this macro may give a noticable performance boost, it
///   will also result in **undefined behaviour** and **cryptic error messages**
///   if an error occurs.
///
///   If you are getting errors in your game, and you suspect Catspeak may be
///   the cause, make sure to re-enable debug mode if you have it disabled.
///
/// @return {Bool}
#macro CATSPEAK_DEBUG_MODE true

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {String} src
/// @return {Id.Buffer}
function __catspeak_create_buffer_from_string(src) {
    return catspeak_util_buffer_create_from_string(src);
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_location_show(location, filepath) {
    gml_pragma("forceinline");
    return catspeak_location_show(location, filepath);
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_location_show_ext(location, filepath) {
    var msg = __catspeak_location_show(location, filepath);
    if (argument_count > 2) {
        msg += " -- ";
        for (var i = 2; i < argument_count; i += 1) {
            msg += __catspeak_string(argument[i]);
        }
    }
    return msg;
}

/// Gets the line component of a Catspeak source location. This is stored as a
/// 20-bit unsigned integer within the least-significant bits of the supplied
/// Catspeak location handle.
///
/// @deprecated {4.0.0}
///   Use `catspeak_location_get_line` instead.
///
/// @param {Real} location
///   A 32-bit integer representing the diagnostic information of a Catspeak
///   program.
///
/// @returns {Real}
function catspeak_location_get_row(location) {
    gml_pragma("forceinline");
    return catspeak_location_get_line(location);
}

/// At times, Catspeak creates a lot of garbage which tends to have a longer
/// lifetime than is typically expected.
///
/// Calling this function forces Catspeak to collect that garbage.
///
/// @deprecated {4.0.0}
function catspeak_collect() {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
    }
    var pool = global.__catspeakAllocPool;
    var poolSize = array_length(pool)-1;
    for (var i = poolSize; i >= 0; i -= 1) {
        var weakRef = pool[i];
        if (weak_ref_alive(weakRef)) {
            continue;
        }
        weakRef.adapter.destroy(weakRef.ds);
        array_delete(pool, i, 1);
    }
}

/// "adapter" here is a struct with two fields: "create" and "destroy" which
/// indicates how to construct and destruct the resource once the owner gets
/// collected.
///
/// "owner" is a struct whose lifetime determines whether the resource needs
/// to be collected as well. Once "owner" gets collected by the garbage
/// collector, any resources it owns will eventually get collected as well.
///
/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
/// @param {Struct} adapter
/// @return {Any}
function __catspeak_alloc(owner, adapter) {
    var pool = global.__catspeakAllocPool;
    var poolMax = array_length(pool) - 1;
    if (poolMax >= 0) {
        repeat (3) { // the number of retries until a new resource is created
            var i = irandom(poolMax);
            var weakRef = pool[i];
            if (weak_ref_alive(weakRef)) {
                continue;
            }
            weakRef.adapter.destroy(weakRef.ds);
            var newWeakRef = weak_ref_create(owner);
            var resource = adapter.create();
            newWeakRef.adapter = adapter;
            newWeakRef.ds = resource;
            pool[@ i] = newWeakRef;
            return resource;
        }
    }
    var weakRef = weak_ref_create(owner);
    var resource = adapter.create();
    weakRef.adapter = adapter;
    weakRef.ds = resource;
    array_push(pool, weakRef);
    return resource;
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_map(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSMapAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_list(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSListAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_stack(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSStackAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
///
/// @param {Struct} owner
function __catspeak_alloc_ds_priority(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSPriorityAdapter);
}

/// @ignore
///
/// @deprecated {4.0.0}
function __catspeak_init_alloc() {
    /// @ignore
    global.__catspeakAllocPool = [];
    /// @ignore
    global.__catspeakAllocDSMapAdapter = {
        create : ds_map_create,
        destroy : ds_map_destroy,
    };
    /// @ignore
    global.__catspeakAllocDSListAdapter = {
        create : ds_list_create,
        destroy : ds_list_destroy,
    };
    /// @ignore
    global.__catspeakAllocDSStackAdapter = {
        create : ds_stack_create,
        destroy : ds_stack_destroy,
    };
    /// @ignore
    global.__catspeakAllocDSPriorityAdapter = {
        create : ds_priority_create,
        destroy : ds_priority_destroy,
    };
}