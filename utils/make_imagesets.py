#!/usr/bin/env python

from pathlib import Path
import re
import sys
from argparse import ArgumentParser


def to_roman_numeral(num: int):
    lookup = [
        (1000, "M"),
        (900, "CM"),
        (500, "D"),
        (400, "CD"),
        (100, "C"),
        (90, "XC"),
        (50, "L"),
        (40, "XL"),
        (10, "X"),
        (9, "IX"),
        (5, "V"),
        (4, "IV"),
        (1, "I"),
    ]
    res = ""
    for n, roman in lookup:
        (d, num) = divmod(num, n)
        res += roman * d
    return res


if __name__ == "__main__":
    description = """
    This script is used to generate the image sets for LaTeX.
    It takes the directory structure and image files in `images` or `images_preview` and creates
    a file `imagesets.tex` that contains lists that are meant to be used with the `listofitems` LaTeX
    package.
    """
    parser = ArgumentParser(description=description)
    parser.add_argument("--preview", action="store_true", default=False)
    args = parser.parse_args()

    if args.preview:
        img_root = Path("./images_preview")
    else:
        img_root = Path("./images")

    with open("imagesets.tex", "w") as out:
        # A "group" is any subdirectory in the images directory
        for group in filter((lambda d: d.is_dir()), sorted(img_root.iterdir())):
            # All images in the subdirectory are part of the group
            images = sorted(
                str(x.with_suffix("")) for x in group.iterdir() if x.is_file()
            )
            # The name of the subdirectory is the group name - we need to clean up the name to make it LaTeX safe (no digits, no underscores)
            group_name = re.sub(
                r"\d+", (lambda m: to_roman_numeral(int(m.group(0)))), group.name
            )
            group_name = "".join(
                part[0].upper() + part[1:] for part in re.split(r"[-_]", group_name)
            )
            group_name = f"IS{group_name}"

            # Write the group definition
            print(f"\\edef\\{group_name}{{{' '.join(images)}}}", file=out)
