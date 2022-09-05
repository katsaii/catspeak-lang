//! Handles the code execution stage of the Catspeak runtime.

//# feather use syntax-errors

/// Creates a new Catspeak virtual machine, responsible for the execution
/// of Catspeak IR.
function CatspeakVM() constructor {
    self.returnValue = undefined;
    self.callFrames = [];
    self.callHead = -1;
    self.callCapacity = 0;

    /// Creates a new executable callframe for this IR.
    ///
    /// @param {Struct} self_
    ///   The "self" scope to use when calling this function.
    ///
    /// @param {Struct.CatspeakIR} ir
    ///   The Catspeak IR to execute. The VM is pretty stupid, so if the code is
    ///   not well-formed, there are likely to be runtime errors and misbehaviour.
    ///
    /// @param {Array<Any>} [args]
    ///   The arguments to pass to this VM call.
    static pushCallFrame = function(self_, ir, args) {
        var callHead_ = callHead + 1;
        var callCapacity_ = callCapacity;
        callHead = callHead_;
        var callFrame;
        if (callHead_ == callCapacity_) {
            // create an entirely new frame
            callFrame = { };
            array_push(callFrames, callFrame);
            callCapacity = callCapacity_ + 1;
        } else {
            // use the existing callframe
            callFrame = callFrames[callHead_];
            if (callFrame.ir == ir) {
                // simplified initialisation
                callFrame.self_ = self_;
                callFrame.args = args ?? [];
                callFrame.pc = 0;
                callFrame.block = callFrame.initialBlock;
                return;
            }
        }
        // set up a new frame from scratch
        var initialBlock = ir.blocks[0].code;
        var registerCount = array_length(ir.registers);
        callFrame.self_ = self_;
        callFrame.ir = ir;
        callFrame.args = args ?? [];
        callFrame.registers = array_create(registerCount);
        callFrame.constants = ir.constants;
        callFrame.pc = 0;
        callFrame.initialBlock = initialBlock;
        callFrame.block = initialBlock;
    };

    /// An unsafe function which can be used as a shortcut if you are going
    /// to reuse the previous callframe with the same settings. There are no
    /// checks that a valid callframe even exists, so keep that in mind.
    static reuseCallFrame = function() {
        var callHead_ = callHead + 1;
        callHead = callHead_;
        var callFrame = callFrames[callHead_];
        callFrame.pc = 0;
        callFrame.block = callFrame.initialBlock;
    };

    /// An unsafe function similar to `reuseCallFrame`, except a new set of
    /// arguments can be passed into the frame.
    ///
    /// @param {Struct} self_
    ///   The "self" scope to use when calling this function.
    ///
    /// @param {Array<Any>} args
    ///   The arguments to pass to this VM call.
    static reuseCallFrameWithArgs = function(self_, args) {
        reuseCallFrame();
        var callFrame = callFrames[callHead];
        callFrame.self_ = self_;
        callFrame.args = args;
    };

    /// Removes the top callframe from the stack.
    static popCallFrame = function() {
        callHead -= 1;
    };

    /// Returns whether the VM is in progress.
    static inProgress = function() {
        return callHead >= 0;
    };

    /// Performs a single step of the execution process. Just like the
    /// compiler, these steps try to be discrete so that the VM can be paused
    /// if necessary. However, this does not account for external code that
    /// may perform large amounts of processing, such as a GML function
    /// containing a computationally expensive loop.
    static runProgram = function() {
        var callFrame_ = callFrames[callHead];
        var pc = callFrame_.pc;
        var r = callFrame_.registers;
        var c = callFrame_.constants;
        var inst = callFrame_.block[pc];
        switch (inst[0]) {
        case CatspeakIntcode.JMP:
            callFrame_.block = inst[2].code;
            callFrame_.pc = 0;
            break;
        case CatspeakIntcode.JMP_FALSE:
            if (__catspeak_vm_get_mem(r, c, inst[3])) {
                callFrame_.pc = pc + 1;
            } else {
                callFrame_.block = inst[2].code;
                callFrame_.pc = 0;
            }
            break;
        case CatspeakIntcode.MOV:
            r[@ inst[1]] = __catspeak_vm_get_mem(r, c, inst[2]);
            callFrame_.pc = pc + 1;
            break;
        case CatspeakIntcode.LDC:
            // not implemented right now
            callFrame_.pc = pc + 1;
            break;
        case CatspeakIntcode.ARG:
            r[@ inst[1]] = callFrame_.args;
            callFrame_.pc = pc + 1;
            break;
        case CatspeakIntcode.RET:
            returnValue = __catspeak_vm_get_mem(r, c, inst[2]);
            popCallFrame();
            break;
        case CatspeakIntcode.CALL:
            // TODO support calling Catspeak functions
            var callee = __catspeak_vm_get_mem(r, c, inst[2]);
            var argCount = array_length(inst) - 3;
            var args = array_create(argCount);
            for (var i = 0; i < argCount; i += 1) {
                args[@ i] = __catspeak_vm_get_mem(r, c, inst[3 + i]);
            }
            var result = __catspeak_vm_function_execute(
                    callFrame_.self_, callee, argCount, args);
            r[@ inst[1]] = result;
            callFrame_.pc = pc + 1;
            break;
        default:
            throw new CatspeakError(undefined, "invalid VM instruction");
            break;
        }
    };
}

/// @ignore
function __catspeak_vm_function_execute(self_, f, argc, args) {
    gml_pragma("forceinline");
    var f_ = f;
    var self__ = self_;
    if (is_method(f_)) {
        self__ = method_get_self(f_) ?? self__;
        f_ = method_get_index(f_);
    }
    with(self__) {
        return script_execute_ext(f_, args);
    }
}

/// @ignore
function __catspeak_vm_get_mem(registers, constants, reg) {
    gml_pragma("forceinline");
    if (reg < 0) {
        return constants[-(reg + 1)];
    } else {
        return registers[reg];
    }
}