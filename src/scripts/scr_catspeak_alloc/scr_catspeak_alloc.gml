//! Handles the allocation of dynamic resources that need to be garbage
//! collected manually.

//# feather use syntax-errors

/// Allocates a new DSMap resource and returns its ID.
///
/// @param {Struct} struct
///   The struct whose lifetime determines how long the DSMap lives.
///
/// @return {Id.DsMap}
function catspeak_alloc_ds_map(struct) {
    gml_pragma("forceinline");
    return catspeak_alloc(struct, global.__catspeakAllocDSMapAdapter);
}

/// Allocates a new DSList resource and returns its ID.
///
/// @param {Struct} struct
///   The struct whose lifetime determines how long the DSList lives.
///
/// @return {Id.DsList}
function catspeak_alloc_ds_list(struct) {
    gml_pragma("forceinline");
    return catspeak_alloc(struct, global.__catspeakAllocDSListAdapter);
}

/// Allocates a new resource with the same lifetime as a given struct.
///
/// @param {Struct} struct
///   The struct whose lifetime determines how long the resource lives.
///
/// @param {Struct} adapter
///   A struct containing two fields: `create` and `destroy`. The `create`
///   field contains a function which is called to construct the resource.
///   The `destroy` field is a function expecting a single parameter, used
///   to destroy the allocated resource.
///
/// @return {Any}
function catspeak_alloc(struct, adapter) {
    var pool = global.__catspeakAllocPool;
    var poolMax = array_length(pool) - 1;
    if (poolMax >= 0) {
        repeat (3) { // the number of retries until a new map is created
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