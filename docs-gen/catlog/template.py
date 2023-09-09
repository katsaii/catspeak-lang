from textwrap import dedent

CSS = dedent("""
    * { outline : solid red 1px }
""")

HEAD_ENTER = dedent("""
    <!DOCTYPE html>
    <!--
        AUTOMATICALLY GENERATED USING THE CATSPEAK BOOK GENERATOR:
        https://github.com/katsaii/catspeak-lang
    -->
    <html lang="en">
    <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <!-- HEAD_ENTER -->
""")

HEAD_EXIT = dedent("""
    <!-- HEAD_EXIT -->
    </head>\
""")

BODY_ENTER = dedent("""
    <body>
    <!-- BODY_ENTER -->
""")

BODY_EXIT = dedent("""
    <!-- BODY_EXIT -->
    </body>
    </html>\
""")

#<link rel="preconnect" href="https://fonts.googleapis.com">
#<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
#<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Ubuntu+Mono:ital,wght@0,400;0,700;1,400&display=swap">
#<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Courier+Prime&display=swap">

#<meta name="author" content="Kat @katsaii">
#<meta name="description" content="A cross-platform, expression oriented programming language for implementing modding support into your GameMaker Studio 2.3 games. >(OwO)<">
#<title>Catspeak Reference</title>