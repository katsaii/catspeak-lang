//! Handles the code execution stage of the Catspeak runtime.

//# feather use syntax-errors

/// Creates a new Catspeak virtual machine, responsible for the execution
/// of Catspeak IR.
///
/// @param {Struct.CatspeakIR} ir
///   The Catspeak IR to execute. The VM is pretty stupid, so if the code is
///   not well-formed, there are likely to be runtime errors and misbehaviour.
function CatspeakVM(ir) constructor {
    self.ir = ir;
}