//! The Catspeak engine creates a lot of garbage sometimes, this module is
//! responsible for the allocation and collection of that garbage.

//# feather use syntax-errors

/// Forces the Catspeak engine to collect any discarded resources.
function catspeak_collect() {
    if (CATSPEAK_DEBUG_MODE) {
        __catspeak_check_init();
    }
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
/// @param {Struct} owner
function __catspeak_alloc_ds_map(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSMapAdapter);
}

/// @ignore
///
/// @param {Struct} owner
function __catspeak_alloc_ds_list(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSListAdapter);
}

/// @ignore
///
/// @param {Struct} owner
function __catspeak_alloc_ds_stack(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSStackAdapter);
}

/// @ignore
///
/// @param {Struct} owner
function __catspeak_alloc_ds_priority(owner) {
    gml_pragma("forceinline");
    return __catspeak_alloc(owner, global.__catspeakAllocDSPriorityAdapter);
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