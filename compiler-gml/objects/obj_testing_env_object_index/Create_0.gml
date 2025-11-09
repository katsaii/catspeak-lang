var env = new CatspeakEnvironment();

env.getInterface().exposeFunction("print", show_debug_message);
funny_function = env.compile(env.parseString("print(self.id)"));
catspeak_execute_ext_v3(funny_function, id);