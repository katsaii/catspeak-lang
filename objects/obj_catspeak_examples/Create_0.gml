/// @desc Initialise examples.
show_debug_overlay(true);
catspeak_set_frame_allocation(0.5); // compute for 50% of the frame if possible
catspeak_set_frame_threshold(0.75); // do not surpass 75% of the current frame
// parsing JSON using Catspeak
jsonObj = catspeak_ext_json_parse(@'
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
show_message("JSON result:\n" + json_stringify(jsonObj));
// configuration example
configSession = catspeak_session_create();
playerData = undefined;
worldData = undefined;
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
// heavy processing example
processingSession = catspeak_session_create();
catspeak_session_set_source(processingSession, @'
    countdown = 15000
    while countdown {
        if (countdown % 5000 == 0) {
            print countdown
        }
        countdown = countdown - 1
    }
');
catspeak_session_create_process(processingSession, function(_) {
    show_message("countdown complete!");
});
// external function rendering
var eager = catspeak_session_create();
catspeak_session_add_function(eager, "draw_text", draw_text);
catspeak_session_add_function(eager, "mouse_get_x", function() { return mouse_x; });
catspeak_session_add_function(eager, "mouse_get_y", function() { return mouse_y; });
catspeak_session_set_source(eager, @'
    return : extern fun {
        draw_text (run mouse_get_x) (run mouse_get_y) "hello from Catspeak"
    }
');
catspeakDrawFunction = catspeak_session_create_process_greedy(eager);
catspeak_session_destroy(eager);