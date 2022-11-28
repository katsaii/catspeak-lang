//! Handles the code execution stage of the Catspeak runtime.

//# feather use syntax-errors

/// Creates a new Catspeak virtual machine, responsible for the execution
/// of Catspeak IR.
function CatspeakVM() constructor {
    self.returnValue = undefined;
    self.callFrames = [];
    self.callHead = -1;
    self.callCapacity = 0;
    self.args = [];

    /// Creates a new executable callframe for this IR.
    ///
    /// @param {Struct} self_
    ///   The "self" scope to use when calling this function.
    ///
    /// @param {Struct.CatspeakFunction} ir
    ///   The Catspeak IR to execute. The VM is pretty stupid, so if the code is
    ///   not well-formed, there are likely to be runtime errors and misbehaviour.
    ///
    /// @param {Array<Any>} [args]
    ///   The arguments to pass to this VM call.
    ///
    /// @param {Real} [argo]
    ///   The offset in the arguments array to start at.
    ///
    /// @param {Real} [argc]
    ///   The number of arguments in the arguments array.
    static pushCallFrame = function(self_, ir, args, argo, argc) {
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
                callFrame.self_ = self_ ?? other;
                callFrame.args = args ?? [];
                callFrame.argo = argo ?? 0;
                callFrame.argc = argc ?? array_length(callFrame.args);
                callFrame.pc = 0;
                callFrame.block = callFrame.initialBlock;
                return;
            }
        }
        // set up a new frame from scratch
        var initialBlock = ir.blocks[0].code;
        var registerCount = array_length(ir.registers);
        callFrame.self_ = self_ ?? other;
        callFrame.ir = ir;
        callFrame.args = args ?? [];
        callFrame.argo = argo ?? 0;
        callFrame.argc = argc ?? array_length(callFrame.args);
        callFrame.registers = array_create(registerCount);
        callFrame.globals = ir.globalRegisters;
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

    /// An unsafe function similar to [reuseCallFrame], except a new set of
    /// arguments can be passed into the frame.
    ///
    /// @param {Array<Any>} args
    ///   The arguments to pass to this VM call.
    ///
    /// @param {Real} [argo]
    ///   The offset in the arguments array to start at.
    ///
    /// @param {Real} [argc]
    ///   The number of arguments in the arguments array.
    static reuseCallFrameWithArgs = function(args, argo, argc) {
        reuseCallFrame();
        var callFrame = callFrames[callHead];
        callFrame.args = args;
        callFrame.argo = argo ?? 0;
        callFrame.argc = argc ?? array_length(args);
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
        var callFrames_ = callFrames;
        var callFrame = callFrames_[callHead];
        var pc = callFrame.pc;
        var r = callFrame.registers;
        var g = callFrame.globals;
        var block = callFrame.block;
        var self_ = callFrame.self_;
        var args_ = args;
        repeat (n) {
            var inst = block[pc];
            var code = inst[0];
            switch (code) {
            case CatspeakIntcode.LDC:
                array_copy(r, inst[1], inst, 3, inst[2]);
                pc += 1;
                break;
            case CatspeakIntcode.CALLSPAN:
            case CatspeakIntcode.CALL:
                var callself = inst[2];
                var callee = r[inst[3]];
                var argC, argO, argB;
                if (code == CatspeakIntcode.CALL) {
                    argC = inst[5];
                    argO = inst[4];
                    argB = r;
                } else {
                    var spanCount = inst[4];
                    var instOffset = 5;
                    var argOffset = 0;
                    repeat (spanCount) {
                        var spanReg = inst[instOffset];
                        var spanLength = inst[instOffset + 1];
                        array_copy(args, argOffset, r, spanReg, spanLength);
                        instOffset += 2;
                        argOffset += spanLength;
                    }
                    argC = argOffset;
                    argO = 0;
                    argB = args_;
                }
                if (callself == undefined) {
                    callself = self;
                } else {
                    callself = r[callself];
                }
                if (instanceof(callee) == "CatspeakFunction") {
                    // call Catspeak function
                    callFrame.pc = pc;
                    callFrame.block = block;
                    pushCallFrame(callself, callee, argB, argO, argC);
                    callFrame = callFrames_[callHead];
                    pc = callFrame.pc;
                    r = callFrame.registers;
                    g = callFrame.globals;
                    block = callFrame.block;
                    self_ = callFrame.self_;
                } else {
                    // call GML function
                    r[@ inst[1]] = __catspeak_vm_function_execute(
                            callself, callee, argC, argO, argB);
                    pc += 1;
                }
                break;
            case CatspeakIntcode.JMP:
                block = inst[2].code;
                pc = 0;
                break;
            case CatspeakIntcode.JMPF:
                if (r[inst[3]]) {
                    pc += 1;
                } else {
                    block = inst[2].code;
                    pc = 0;
                }
                break;
            case CatspeakIntcode.GGET:
                r[@ inst[1]] = g[inst[2]];
                pc += 1;
                break;
            case CatspeakIntcode.GSET:
                g[@ inst[2]] = r[inst[3]];
                pc += 1;
                break;
            case CatspeakIntcode.SELF:
                r[@ inst[1]] = self_;
                pc += 1;
                break;
            case CatspeakIntcode.MOV:
                array_copy(r, inst[1], r, inst[3], inst[2]);
                pc += 1;
                break;
            case CatspeakIntcode.LDA:
                var callArgs = callFrame.args;
                var callArgo = callFrame.argo;
                var callArgc = callFrame.argc;
                var dest = inst[1];
                var destArgc = inst[2];
                if (destArgc <= callArgc) {
                    array_copy(r, dest, callArgs, callArgo, destArgc);
                } else {
                    array_copy(r, dest, callArgs, callArgo, callArgc);
                    dest += callArgc;
                    repeat (destArgc - callArgc) {
                        r[@ dest] = undefined;
                        dest += 1;
                    }
                }
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
                g = callFrame.globals;
                block = callFrame.block;
                self_ = callFrame.self_;
                r[@ block[pc][1]] = returnValue;
                pc += 1;
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