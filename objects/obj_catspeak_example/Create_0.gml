/// @desc Initialise variables.
frameStartTime = 0;
show_debug_overlay(true);
session = catspeak_session_create();
catspeak_session_enable_implicit_return(session, true);
catspeak_set_max_iterations(1000);
catspeak_session_add_function(session, "pred", function(_x) { return _x - 1; });
catspeak_session_set_source(session, @'
{
    "glossary": {
        "title": "example glossary",
        "GlossDiv": {
            "title": "S",
            "GlossList": {
                "GlossEntry": {
                    "ID": "SGML",
                    "SortAs": "SGML",
                    "GlossTerm": "Standard Generalized Markup Language",
                    "Acronym": "SGML",
                    "Abbrev": "ISO 8879:1986",
                    "GlossDef": {
                        "para": "A meta-markup language, used to create markup languages such as DocBook.",
                        "GlossSeeAlso": ["GML", "XML"]
                    },
                    "GlossSee": "markup"
                }
            }
        }
    }
}
');
show_message(catspeak_session_create_process_eager(session));
catspeak_session_create_process(session, function(_value) {
    show_message(_value);
});