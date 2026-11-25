# Contributing to Catspeak

Thank you for being interested in contributing to Catspeak. However, the repo
you are looking for actually exists over on [Codeberg](https://codeberg.org/katsaii/catspeak-lang).

Contributions to the documentation are not welcome, sorry!

## Building the Documentation

**OUT OF DATE! MAY NOT WORK!**

0. (prerequisite) Make sure Mistletoe EBP in installed:
   ```sh
   python -m venv venv
   venv/bin/pip install mistletoe-ebp
   ```
   or
   ```sh
   python -m venv venv
   source venv/bin/activate
   venv/bin/pip install -r requirements.txt
   ```
   more info: https://mistletoe-ebp.readthedocs.io/en/latest/using/intro.html#installation
1. Open a new terminal window.
2. Navigate to the root directory of this repo, you should see a directory named
   `docs-gen`.
3. Run
   ```sh
   venv/bin/python ./docs-gen/build-docs.py
   ```

If you encounter no errors, then a new documentation page will be written to
`docs/<version>`.