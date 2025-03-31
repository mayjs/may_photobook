# May Photobook

This is a small framework and template to build photobooks in LaTeX using the [photobook class](https://ctan.org/pkg/photobook?lang=en).
It is built to work with square 19x19cm photobooks that need one double page on one pdf page.

## How to Setup a New Photobook

It is recommended to use this repository with [Nix](https://nixos.org/), but you can also use it without Nix.

### With Nix

### Without Nix

Copy the contents of this repository and install the required dependencies manually.
You are going to need:

* A LaTeX distribution that includes the photobook class
* Python 3
* jhead
* just
* epeg
* GNU parallel
* podofo
* poppler utilities

## How to Use

### Building the Photobook

You can use `just build` to build the photobook.
If you want a low resolution preview, use `just build-preview` instead.

Some printing shops will not handle the PDF boxes in the resulting PDF correctly.
If this is the case for you, run `just strip-pdf-boxes`.
This will create a new file `book_no_boxes.pdf` where all PDF boxes are identical.

### Adding New Content to the Photobook

The steps to add new pages to a photobook using this framework are:

1. Create a new directory for the page in the `images` directory
2. Copy the images for the page to the new directory
3. Run `just create-preview-images` to sanitize the new images, update the preview images and update `imagesets.tex`
4. Create a new page in `book.tex` and use the new image set from `imagesets.tex` with the layouts defined in `customlayouts.sty`

### Formatting

If you use Nix, you can format the entire repository using `nix fmt`.

### Code Checking

If you use Nix, you can run `shellcheck` using `nix flake check`.
