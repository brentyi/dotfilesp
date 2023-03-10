#!/usr/bin/env python3

import sys
import os
import pathlib

# Does a find and replace on file/directory names
#
# Usage:
#   ./find_and_replace.py FIND_TEXT REPLACE_TEXT
#
# To do the same on file contents:
# $ find . -type f -name "*.txt" -print0 | xargs -0 sed -i '' -e 's/foo/bar/g'

assert len(sys.argv) == 3

find_text = sys.argv[1]
replace_text = sys.argv[2]

paths = [str(path) for path in pathlib.Path().rglob("*")]
for current_path in paths:
    if find_text in current_path and "./" not in current_path and not current_path.startswith("."):
        new_path = current_path.replace(find_text, replace_text)
        os.rename(current_path, new_path)
        print("Moving: {} to {}".format(current_path, new_path))
