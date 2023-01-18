# Contributing to Catspeak

Thank you for being interested in contributing to Catspeak. Please don't try to
push directly to this repo, it wont work. Instead, fork this repo and make your
changes there.

For more information, read the guidelines supplied by [GitHub](https://docs.github.com/en/get-started/quickstart/contributing-to-projects).

## Contributing Guidelines

### Issues

If you notice a problem with Catspeak, feel free to create an issue using the
[issue form](https://github.com/katsaii/catspeak-lang/issues/new). If you have
multiple issues you want to report, please report them separately instead of as
a monolithic task. Once you have created an issue, it may be updated with
[certain tags](https://github.com/katsaii/catspeak-lang/labels) depending on its
content.

If you would like to work on solving an issue, feel free to pick one and work
on it. I wont assign issues to anyone.

### Style

Please try your best to follow the style of any surrounding code. Here are some
brief tips:
 - Indentation uses 4 spaces, **please do not use tabs**.
 - Follow the [K&R](https://en.wikipedia.org/wiki/Indentation_style#K&R_style) style for brackets.
 - Do not use multi-line comments.
 - Do not exceed 80 characters per line.
 - Do not use legacy delphi keywords and operators, examples include:
   - `begin` and `end`
   - The `:=` assignment operator
   - The `=` and `<>` comparison operators
 - Ensure **all** statements end in a semi-colon.

I will still probably merge your PR if your code deviates from the style, but
please try and keep the codebase consistent.
