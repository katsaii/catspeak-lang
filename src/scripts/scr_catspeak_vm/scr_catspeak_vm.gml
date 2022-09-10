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
    /// @param {Real} n
    ///   The number of steps of process.
    static runProgram = function(n) {
        var callFrame = callFrames[callHead];
        var pc = callFrame.pc;
        var r = callFrame.registers;
        var block = callFrame.block;
        var self_ = callFrame.self_;
        var args_ = args;
        repeat (n) {
            var inst = block[pc];
            switch (inst[0]) {
            case CatspeakIntcode.LDC:
                array_copy(r, inst[1], inst, 3, inst[2]);
                pc += 1;
                break;
            case CatspeakIntcode.CALL_SIMPLE:
                var callee = r[inst[2]];
                var result = __catspeak_vm_function_execute(
                        self_, callee, inst[4], inst[3], r);
                r[@ inst[1]] = result;
                pc += 1;
                break;
            case CatspeakIntcode.CALL:
                // TODO support calling Catspeak functions
                var callee = r[inst[2]];
                var spanCount = inst[3];
                var instOffset = 4;
                var argOffset = 0;
                repeat (spanCount) {
                    var spanReg = inst[instOffset];
                    var spanLength = inst[instOffset + 1];
                    array_copy(args, argOffset, r, spanReg, spanLength);
                    instOffset += 2;
                    argOffset += spanLength;
                }
                var result = __catspeak_vm_function_execute(
                        self_, callee, argOffset, 0, args_);
                r[@ inst[1]] = result;
                pc += 1;
                break;
            case CatspeakIntcode.JMP:
                block = inst[2].code;
                pc = 0;
                break;
            case CatspeakIntcode.JMP_FALSE:
                if (r[inst[3]]) {
                    pc += 1;
                } else {
                    block = inst[2].code;
                    pc = 0;
                }
                break;
            case CatspeakIntcode.IMPORT:
                r[@ inst[1]] = prelude[$ inst[2]];
                pc += 1;
                break;
            case CatspeakIntcode.MOV:
                r[@ inst[1]] = r[inst[2]];
                pc += 1;
                break;
            case CatspeakIntcode.ARG:
                r[@ inst[1]] = callFrame.args;
                pc += 1;
                break;
            case CatspeakIntcode.RET:
                returnValue = r[inst[2]];
                popCallFrame();
                if (callHead < 0) {
                    // exit early
                    return;
                }
                callFrame = callFrames[callHead];
                pc = callFrame.pc;
                r = callFrame.registers;
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
function __catspeak_vm_function_execute(self_, f, argc, argO, args) {
    gml_pragma("forceinline");
    var f_ = f;
    var scrSelf = method_get_self(f_) ?? self_;
    var scr = method_get_index(f_);
    if (scr == __catspeak_builtin_array) {
        // array create shortcut
        var arr = array_create(argc);
        array_copy(arr, 0, args, argO, argc);
        return arr;
    }
    with (scrSelf) {
        return script_execute_ext(scr, args, argO, argc);
    }
}