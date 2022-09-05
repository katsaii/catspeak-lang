//! Handles the code execution stage of the Catspeak runtime.

//# feather use syntax-errors

/// Creates a new Catspeak virtual machine, responsible for the execution
/// of Catspeak IR.
///
/// @param {Struct} [prelude]
///   The globally available constants which are able to be accessed by
///   Catspeak programs. Defaults to nothing.
function CatspeakVM(prelude) constructor {
    self.returnValue = undefined;
    self.callFrames = [];
    self.callHead = -1;
    self.callCapacity = 0;
    self.args = [];
    self.argsCapacity = 0;
    self.prelude = prelude ?? { };

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

    /// Performs a `n`-many steps of the execution process. Just like the
    /// compiler, these steps try to be discrete so that the VM can be paused
    /// if necessary. However, this does not account for external code that
    /// may perform large amounts of processing, such as a GML function
    /// containing a computationally expensive loop.
    ///
    /// @param {Real} [n]
    ///   The number of steps of process, defaults to 1.
    static runProgram = function(n=1) {
        var callFrame = callFrames[callHead];
        var pc = callFrame.pc;
        var r = callFrame.registers;
        var c = callFrame.constants;
        var block = callFrame.block;
        var argsCapacity_ = argsCapacity;
        var args_ = args;
        repeat (n) {
            var inst = block[pc];
            switch (inst[0]) {
            case CatspeakIntcode.CALL:
                // TODO support calling Catspeak functions
                var callee = __catspeak_vm_get_mem(r, c, inst[2]);
                if (is_method(callee)) {
                    var argCount = array_length(inst) - 3;
                    if (argCount > argsCapacity_) {
                        array_resize(args_, argCount);
                        argsCapacity_ = argCount;
                        argsCapacity = argsCapacity_;
                    }
                    for (var i = 0; i < argCount; i += 1) {
                        args_[@ i] = __catspeak_vm_get_mem(r, c, inst[3 + i]);
                    }
                    var result = __catspeak_vm_function_execute(
                            callFrame.self_, callee, argCount, args_);
                    r[@ inst[1]] = result;
                    pc += 1;
                } else {
                    var ir = callFrame.ir;
                    var reg = inst[2];
                    var pos = reg < 0 ? undefined : ir.registers[reg].pos;
                    throw new CatspeakError(pos, "value is not callable");
                }
                break;
            case CatspeakIntcode.JMP:
                block = inst[2].code;
                pc = 0;
                break;
            case CatspeakIntcode.JMP_FALSE:
                if (__catspeak_vm_get_mem(r, c, inst[3])) {
                    pc += 1;
                } else {
                    block = inst[2].code;
                    pc = 0;
                }
                break;
            case CatspeakIntcode.MOV:
                r[@ inst[1]] = __catspeak_vm_get_mem(r, c, inst[2]);
                pc += 1;
                break;
            case CatspeakIntcode.LDC:
                r[@ inst[1]] = prelude[$ inst[2]];
                pc += 1;
                break;
            case CatspeakIntcode.ARG:
                r[@ inst[1]] = callFrame.args;
                pc += 1;
                break;
            case CatspeakIntcode.RET:
                returnValue = __catspeak_vm_get_mem(r, c, inst[2]);
                popCallFrame();
                if (callHead < 0) {
                    // exit early
                    return;
                }
                callFrame = callFrames[callHead];
                pc = callFrame.pc;
                r = callFrame.registers;
                c = callFrame.constants;
                block = callFrame.block;
                break;
            default:
                throw new CatspeakError(undefined, "invalid VM instruction");
                break;
            }
        }
        callFrame.pc = pc;
        callFrame.block = block;
    };
}

/// @ignore
function __catspeak_vm_function_execute(self_, f, argc, args) {
    gml_pragma("forceinline");
    var f_ = f;
    var scrSelf = method_get_self(f_) ?? self_;
    var scr = method_get_index(f_);
    with (scrSelf) {
        return script_execute_ext(scr, args, 0, argc);
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