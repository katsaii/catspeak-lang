var env = new CatspeakEnvironment();

env.getInterface().exposeFunction("print", show_debug_message);
funny_function = env.compile(env.parseString("print(self.id)"));
funny_function.setSelf(id);
funny_function();