//! TODO

//# feather use syntax-errors

/// TODO
function CatspeakModuleGML(perms_) : CatspeakModule("gm::gml") constructor {
    /// @ignore
    perms = perms_;
    /// @ignore
    __exists__ = function (name) {
        return false;
    };
    /// @ignore
    __get__ = function (name) {
        return undefined;
    };
    /// @ignore
    static db = undefined;
    if (db == undefined) {
        db = { };
        
    }
}