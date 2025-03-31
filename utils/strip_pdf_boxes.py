#!/usr/bin/env python

from subprocess import run
from argparse import ArgumentParser
from pathlib import Path
from dataclasses import dataclass
from decimal import Decimal
import tempfile
import shutil

# Valid boxes are "media", "crop", "bleed", "trim", "art"
# See https://docs.cloudprinter.com/client/pdf-page-boxes-explained for more information


@dataclass
class PdfBox:
    left: Decimal
    bottom: Decimal
    width: Decimal
    height: Decimal


def get_pdf_box(pdf: Path, box: str) -> PdfBox:
    box_prefix = f"{box.capitalize()}Box:"
    res = run(["pdfinfo", "-box", str(pdf)], capture_output=True, check=True)
    for line in res.stdout.decode("utf-8").splitlines():
        if line.strip().startswith(box_prefix):
            (left, bottom, width, height) = list(
                map(
                    lambda p: Decimal(p),
                    filter(lambda p: len(p) > 0, line.split(" ")[1:]),
                )
            )
            return PdfBox(left, bottom, width, height)


def set_pdf_boxes(pdf_in: Path, pdf_out: Path, boxes: list[str], value: PdfBox):
    def decimal_to_podofo(dec: Decimal) -> str:
        return f"{dec * 100:.0f}"

    with tempfile.TemporaryDirectory() as tmpdirname:
        tmpdirpath = Path(tmpdirname)
        current = pdf_in
        # We have to apply the boxes one by one
        for box in boxes:
            next = tmpdirpath / f"{box}.pdf"
            run(
                [
                    "podofobox",
                    str(current),
                    str(next),
                    box,
                    decimal_to_podofo(value.left),
                    decimal_to_podofo(value.bottom),
                    decimal_to_podofo(value.width),
                    decimal_to_podofo(value.height),
                ]
            )
            if current != pdf_in:
                current.unlink()  # Remove the old file if it is not the original input (save some space)
            current = next
        shutil.copy(current, pdf_out)


if __name__ == "__main__":
    parser = ArgumentParser(
        description="Set all boxes in a PDF to the dimensions of its media box. This is required by some printing services. Requires poppler and podofo to be installed."
    )
    parser.add_argument("input", help="The input PDF file")
    parser.add_argument("output", help="The output PDF file")
    args = parser.parse_args()

    box = get_pdf_box(Path(args.input), "media")
    set_pdf_boxes(Path(args.input), Path(args.output), ["art", "trim", "crop"], box)
