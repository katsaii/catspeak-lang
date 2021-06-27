/// @desc Initialise examples.
frameStartTime = 0;
show_debug_overlay(true);
// JSON session
jsonSession = catspeak_session_create();
catspeak_session_enable_implicit_return(jsonSession, true);
catspeak_session_set_source(jsonSession, @'
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
catspeak_session_create_process(jsonSession, function(_value) {
    show_message("JSON result:\n" + json_stringify(_value));
});
// configuration example
configSession = catspeak_session_create();
playerData = undefined;
worldData = undefined;
catspeak_ext_session_add_gml_operators(configSession);
catspeak_session_add_function(configSession, "player", function(_value) {
    playerData = _value;
});
catspeak_session_add_function(configSession, "world", function(_value) {
    worldData = _value;
});
catspeak_session_set_source(configSession, @'
player {
    .name : "Angie"
    .x : -12
    .y : 8
}

world {
    .height : 1000
    .width : 500
    .background_colour : 0x00FF00
}
');
catspeak_session_create_process(configSession, function(_) {
    show_message("player data:\n" + string(playerData));
    show_message("world data:\n" + string(worldData));
});