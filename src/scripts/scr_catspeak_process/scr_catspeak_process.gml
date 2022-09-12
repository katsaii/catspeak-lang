//! Handles the creation of Catspeak processes, and divides execution time
//! between them so each gets a change to progress during the current tick.

/// An interface used by the Catspeak process manager.
///
/// The `update` field should be a function which performs the necessary
/// operations to progress the process. This should not attempt to perform
/// all of the tasks of the process in a single go, otherwise you risk
/// freezing the game.
///
/// The `isBusy` field should be a function which returns `true` or `false`
/// depending on whether the process is still busy with the task.
///
/// Finally, the `result` field should be a function which returns the final
/// result of the completed process.
function CatspeakProcess() constructor {
    self.update = undefined;
    self.isBusy = undefined;
    self.result = undefined;
}

/// Handles the exeuction of Catspeak compilation processes.
///
/// @param {Struct.CatspeakCompiler} compiler
///   The Catspeak compiler to manage.
function CatspeakCompilerProcess(compiler) : CatspeakProcess() constructor {
    self.compiler = compiler;
    self.update = function() { compiler.emitProgram(5) };
    self.isBusy = function() { compiler.inProgress() };
    self.result = function() { return compiler.ir };
}

/// Handles the exeuction of Catspeak runtime processes.
///
/// @param {Struct.CatspeakVM} vm
///   The Catspeak virtual machine to manage.
function CatspeakVMProcess(vm) : CatspeakProcess() constructor {
    self.vm = vm;
    self.update = function() { vm.runProgram(10) };
    self.isBusy = function() { vm.inProgress() };
    self.result = function() { return vm.returnValue };
}