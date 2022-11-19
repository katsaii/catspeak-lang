//! The Catspeak engine creates a lot of garbage sometimes, this module is
//! responsible for the allocation and collection of that garbage.

//# feather use syntax-errors

/// Forces the Catspeak engine to collect any discarded resources.
function catspeak_collect() {
    var pool = global.__catspeakAllocPool;
    var poolSize = array_length(pool);
    for (var i = 0; i < poolSize; i += 1) {
        var weakRef = pool[i];
        if (weak_ref_alive(weakRef)) {
            continue;
        }
        weakRef.adapter.destroy(weakRef.ds);
        array_delete(pool, i, 1);
    }
}

/// @ignore
function __catspeak_alloc(struct, adapter) {
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
            var newWeakRef = weak_ref_create(struct);
            var resource = adapter.create();
            newWeakRef.adapter = adapter;
            newWeakRef.ds = resource;
            pool[@ i] = newWeakRef;
            return resource;
        }
    }
    var weakRef = weak_ref_create(struct);
    var resource = adapter.create();
    weakRef.adapter = adapter;
    weakRef.ds = resource;
    array_push(pool, weakRef);
    return resource;
}

/// @ignore
function __catspeak_alloc_ds_map(struct) {
    gml_pragma("forceinline");
    return __catspeak_alloc(struct, global.__catspeakAllocDSMapAdapter);
}

/// @ignore
function __catspeak_alloc_ds_list(struct) {
    gml_pragma("forceinline");
    return __catspeak_alloc(struct, global.__catspeakAllocDSListAdapter);
}

/// @ignore
function __catspeak_alloc_ds_stack(struct) {
    gml_pragma("forceinline");
    return __catspeak_alloc(struct, global.__catspeakAllocDSStackAdapter);
}

/// @ignore
function __catspeak_alloc_ds_priority(struct) {
    gml_pragma("forceinline");
    return __catspeak_alloc(struct, global.__catspeakAllocDSPriorityAdapter);
}

/// @ignore
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