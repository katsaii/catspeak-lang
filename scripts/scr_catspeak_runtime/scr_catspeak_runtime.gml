/* Catspeak Runtime Environment
 * ----------------------------
 * Kat @katsaii
 */

/// @desc Represents a kind of intcode.
enum CatspeakOpCode {
	PUSH,
	POP,
	VAR_GET,
	VAR_SET,
	REF_GET,
	REF_SET,
	MAKE_ARRAY,
	MAKE_OBJECT,
	PRINT,
	RETURN,
	CALL,
	JUMP,
	JUMP_FALSE
}

/// @desc Displays the ir kind as a string.
/// @param {CatspeakIRKind} kind The ir kind to display.
function catspeak_code_render(_kind) {
	switch (_kind) {
	case CatspeakOpCode.PUSH: return "PUSH";
	case CatspeakOpCode.POP: return "POP";
	case CatspeakOpCode.VAR_GET: return "VAR_GET";
	case CatspeakOpCode.VAR_SET: return "VAR_SET";
	case CatspeakOpCode.REF_GET: return "REF_GET";
	case CatspeakOpCode.REF_SET: return "REF_SET";
	case CatspeakOpCode.MAKE_ARRAY: return "MAKE_ARRAY";
	case CatspeakOpCode.MAKE_OBJECT: return "MAKE_OBJECT";
	case CatspeakOpCode.PRINT: return "PRINT";
	case CatspeakOpCode.RETURN: return "RETURN";
	case CatspeakOpCode.CALL: return "CALL";
	case CatspeakOpCode.JUMP: return "JUMP";
	case CatspeakOpCode.JUMP_FALSE: return "JUMP_FALSE";
	default: return "<unknown>";
	}
}

/// @desc Represents a Catspeak intcode program with associated debug information.
function CatspeakChunk() constructor {
	program = [];
	size = 0;
	/// @desc Returns the size of this chunk.
	static getCurrentSize = function() {
		return size;
	}
	/// @desc Returns an existing code at this program counter.
	/// @param {vector} pos The position of this piece of code.
	static getCode = function(_pos) {
		return program[_pos];
	}
	/// @desc Adds a code and its positional information to the program.
	/// @param {vector} pos The position of this piece of code.
	/// @param {value} code The piece of code to write.
	/// @param {value} param The parameter (if any) associated with this instruction.
	static addCode = function(_pos, _code, _param) {
		array_push(program, {
			pos : _pos,
			code : _code,
			param : _param
		});
		var pc = size;
		size += 1;
		return pc;
	}
	/// @desc Permanently removes a code from the program. Don't use this unless you know what you're doing.
	/// @param {vector} pos The position of this piece of code.
	static removeCode = function(_pos) {
		array_delete(program, _pos, 1);
		size -= 1;
	}
}

/// @desc Handles the creation of interfaces to be used by the Catspeak VM.
function CatspeakVMInterface() constructor {
	vars = { };
	/// @desc Inserts a new constant into to the interface.
	/// @param {string} name The name of the constant.
	/// @param {value} value The value of the constant.
	static addConstant = function(_name, _value) {
		vars[$ _name] = _value;
		return self;
	}
	/// @desc Inserts a new function into to the interface.
	/// @param {string} name The name of the function.
	/// @param {value} method_or_script_id The reference to the function.
	static addFunction = function(_name, _value) {
		var f = _value;
		if not (is_method(f)) {
			// this is so that unexposed functions cannot be enumerated
			// by a malicious user in order to access important functions
			f = method(undefined, f);
		}
		vars[$ _name] = f;
		return self;
	}
}

/// @desc Represents a type of configuration option.
enum CatspeakVMOption {
	GLOBAL_VISIBILITY,
	INSTANCE_VISIBILITY,
	RESULT_HANDLER
}

/// @desc Handles the execution of a single Catspeak chunk.
function CatspeakVM() constructor {
	interfaces = [];
	interfaceCount = 0;
	binding = { };
	resultHandler = undefined;
	chunks = [];
	chunk = undefined;
	pc = 0;
	stackLimit = 8;
	stackSize = 0;
	stack = array_create(stackLimit);
	exposeGlobalScope = false;
	exposeInstanceScope = false;
	/// @desc Throws a `CatspeakError` with the current program counter.
	/// @param {string} msg The error message.
	static error = function(_msg) {
		throw new CatspeakError(chunk.diagnostic[pc], _msg);
	}
	/// @desc Adds a new chunk to the VM to execute.
	/// @param {CatspeakChunk} chunk The chunk to execute code of.
	static addChunk = function(_chunk) {
		if (chunk == undefined) {
			chunk = _chunk;
		} else {
			array_insert(chunks, 0, _chunk);
		}
	}
	/// @desc Removes the chunk currently being executed.
	static terminateChunk = function() {
		if (chunk == undefined) {
			return;
		}
		pc = 0;
		if (array_length(chunks) >= 1) {
			chunk = array_pop(chunks);
		} else {
			chunk = undefined;
		}
	}
	/// @desc Returns whether the VM is in progress.
	static inProgress = function() {
		return chunk != undefined;
	}
	/// @desc Gets the variable workspace for this context.
	static getWorkspace = function() {
		return binding;
	}
	/// @desc Adds an interface to this VM.
	/// @param {struct} vars The context to assign.
	static addInterface = function(_interface) {
		array_push(interfaces, _interface.vars);
		interfaceCount += 1;
		return self;
	}
	/// @desc Sets a configuration option.
	/// @param {CatspeakVMOption} option The option to configure.
	/// @param {bool} enable Whether to enable this option.
	static setOption = function(_option, _enable) {
		switch (_option) {
		case CatspeakVMOption.GLOBAL_VISIBILITY:
			exposeGlobalScope = is_numeric(_enable) && _enable;
			break;
		case CatspeakVMOption.INSTANCE_VISIBILITY:
			exposeInstanceScope = is_numeric(_enable) && _enable;
			break;
		case CatspeakVMOption.RESULT_HANDLER:
			resultHandler = _enable;
			break;
		}
		return self;
	}
	/// @desc Pushes a value onto the stack.
	/// @param {value} value The value to push.
	static push = function(_value) {
		stack[stackSize] = _value;
		stackSize += 1;
		if (stackSize >= stackLimit) {
			stackLimit *= 2;
			array_resize(stack, stackLimit);
		}
	}
	/// @desc Pops the top value from the stack.
	static pop = function() {
		if (stackSize < 1) {
			error("VM stack underflow");
			return undefined;
		}
		stackSize -= 1;
		return stack[stackSize];
	}
	/// @desc Pops `n`-many values from the stack.
	/// @param {real} n The number of elements to pop from the stack.
	static popMany = function(_n) {
		var values = array_create(_n);
		for (var i = _n - 1; i >= 0; i -= 1) {
			values[@ i] = pop();
		}
		return values;
	}
	/// @desc Pops `n`-many values from the stack and inserts them into a struct.
	/// @param {real} n The number of pairs to pop from the stack.
	static popManyKWArgs = function(_n) {
		var values = { };
		repeat (_n) {
			var value = pop();
			var key = pop();
			values[$ string(key)] = value;
		}
		return values;
	}
	/// @desc Returns the top value of the stack.
	static top = function() {
		if (stackSize < 1) {
			error("cannot peek into empty VM stack");
			return undefined;
		}
		return stack[stackSize - 1];
	}
	/// @desc Assigns a value to a variable in the current context.
	/// @param {string} name The name of the variable to add.
	/// @param {value} value The value to assign.
	static setVariable = function(_name, _value) {
		binding[$ _name] = _value;
	}
	/// @desc Gets a variable in the current context.
	/// @param {string} name The name of the variable to add.
	static getVariable = function(_name) {
		if (variable_struct_exists(binding, _name)) {
			return binding[$ _name];
		} else {
			for (var i = interfaceCount - 1; i >= 0; i -= 1) {
				var interface = interfaces[i];
				if (variable_struct_exists(interface, _name)) {
					return interface[$ _name];
				}
			}
			return undefined;
		}
	}
	/// @desc Attempts to index into a container and returns its value.
	/// @param {value} container The container to index.
	/// @param {value} subscript The index to access.
	/// @param {bool} unordered Whether the container is unordered.
	static getIndex = function(_container, _subscript, _unordered) {
		var ty = typeof(_container);
		if (_unordered) {
			switch (ty) {
			case "struct":
				return _container[$ string(_subscript)];
			case "number":
			case "bool":
			case "int32":
			case "int64":
				if (exposeInstanceScope && instance_exists(_container)) {
					return variable_instance_get(_container, _subscript);
				} else if (exposeGlobalScope && _container == global) {
					return variable_global_get(_subscript);
				} else if (ds_exists(_container, ds_type_map)) {
					return _container[? _subscript];
				}
			}
		} else {
			switch (ty) {
			case "array":
				return _container[_subscript];
			case "number":
			case "bool":
			case "int32":
			case "int64":
				if (ds_exists(_container, ds_type_list)) {
					return _container[| _subscript];
				}
			}
		}
		var madlib = _unordered ? "un" : "";
		error("cannot index " + madlib + "ordered collection of type `" + ty + "`");
		return undefined;
	}
	/// @desc Attempts to assign a value to the index of a container.
	/// @param {value} container The container to index.
	/// @param {value} subscript The index to access.
	/// @param {bool} unordered Whether the container is unordered.
	/// @param {value} value The value to insert.
	static setIndex = function(_container, _subscript, _unordered, _value) {
		var ty = typeof(_container);
		if (_unordered) {
			switch (ty) {
			case "struct":
				_container[$ string(_subscript)] = _value;
				return;
			case "number":
			case "bool":
			case "int32":
			case "int64":
				if (exposeInstanceScope && instance_exists(_container)) {
					variable_instance_set(_container, _subscript, _value);
					return;
				} else if (exposeGlobalScope && _container == global) {
					variable_global_set(_subscript, _value);
					return;
				} else if (ds_exists(_container, ds_type_map)) {
					_container[? _subscript] = _value;
					return;
				}
			}
		} else {
			switch (ty) {
			case "array":
				_container[@ _subscript] = _value;
				return;
			case "number":
			case "bool":
			case "int32":
			case "int64":
				if (ds_exists(_container, ds_type_list)) {
					_container[| _subscript] = _value;
					return;
				}
			}
		}
		var madlib = _unordered ? " un" : "";
		error("cannot assign to " + madlib + "ordered collection of type `" + ty + "`");
		return undefined;
	}
	/// @desc Executes a single instruction and updates the program counter.
	static computeProgram = function() {
		var inst = chunk.getCode(pc);
		switch (inst.code) {
		case CatspeakOpCode.PUSH:
			var value = inst.param;
			push(value);
			break;
		case CatspeakOpCode.POP:
			pop();
			break;
		case CatspeakOpCode.VAR_GET:
			var name = inst.param;
			var value = getVariable(name);
			push(value);
			break;
		case CatspeakOpCode.VAR_SET:
			var name = inst.param;
			var value = pop();
			setVariable(name, value);
			break;
		case CatspeakOpCode.REF_GET:
			var unordered = inst.param;
			var subscript = pop();
			var container = pop();
			var value = getIndex(container, subscript, unordered);
			push(value);
			break;
		case CatspeakOpCode.REF_SET:
			var unordered = inst.param;
			var value = pop();
			var subscript = pop();
			var container = pop();
			setIndex(container, subscript, unordered, value);
			break;
		case CatspeakOpCode.MAKE_ARRAY:
			var size = inst.param;
			var container = popMany(size);
			push(container);
			break;
		case CatspeakOpCode.MAKE_OBJECT:
			var size = inst.param;
			var container = popManyKWArgs(size);
			push(container);
			break;
		case CatspeakOpCode.PRINT:
			var value = pop();
			show_debug_message(value);
			break;
		case CatspeakOpCode.JUMP:
			var new_pc = inst.param;
			pc = new_pc;
			return;
		case CatspeakOpCode.JUMP_FALSE:
			var new_pc = inst.param;
			var value = pop();
			if not (is_numeric(value) && value) {
				pc = new_pc;
				return;
			}
			break;
		case CatspeakOpCode.CALL:
			var arg_count = inst.param;
			var callsite, args;
			if (arg_count < 0) {
				// due to how the compiler is implemented, code for operators
				// is generated infix as `a op b`
				var b = pop();
				callsite = pop();
				var a = pop();
				args = [a, b];
			} else {
				args = popMany(arg_count);
				callsite = pop();
			}
			var ty = typeof(callsite);
			switch (ty) {
			case "method":
				var result = executeMethod(callsite, args);
				push(result);
				break;
			default:
				error("invalid call site of type `" + ty + "`");
				break;
			}
			break;
		case CatspeakOpCode.RETURN:
			var value = pop();
			if (resultHandler != undefined) {
				resultHandler(value);
			}
			terminateChunk(); // complete execution
			return;
		default:
			error("unknown program instruction `" + string(inst.code) + "` (" + catspeak_code_render(inst.code) + ")");
			break;
		}
		pc += 1;
	}
	/// @desc Calls a function using an array as the parameter array.
	/// @param {method} ind The id of the method to call.
	/// @param {array} variable The id of the array to pass as a parameter array to this script.
	static executeMethod = function(_f, _a) {
		switch(array_length(_a)){
		case 0: return _f();
		case 1: return _f(_a[0]);
		case 2: return _f(_a[0], _a[1]);
		case 3: return _f(_a[0], _a[1], _a[2]);
		case 4: return _f(_a[0], _a[1], _a[2], _a[3]);
		case 5: return _f(_a[0], _a[1], _a[2], _a[3], _a[4]);
		case 6: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5]);
		case 7: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6]);
		case 8: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7]);
		case 9: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8]);
		case 10: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9]);
		case 11: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10]);
		case 12: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11]);
		case 13: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12]);
		case 14: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13]);
		case 15: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14]);
		case 16: return _f(_a[0], _a[1], _a[2], _a[3], _a[4], _a[5], _a[6], _a[7], _a[8], _a[9], _a[10], _a[11], _a[12], _a[13], _a[14], _a[15]);
		}
		error("argument count of " + string(array_length(_a)) + " is not supported");
		return undefined;
	}
}