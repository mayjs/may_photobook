# Build the full resolution PDF by default
default: build

# Sanitize the images in the images directory by rotating the actual image data according to the EXIF data
sanitize-images:
    find images -type f | parallel jhead -autorot {}

# Create preview images and switch to preview configuration
create-preview-images: sanitize-images
    ./utils/create_preview_images.sh
    ./utils/make_imagesets.py --preview

# Build the preview resolution PDF
build-preview: create-preview-images
    latexmk -pdf book.tex

# Build the full resolution PDF
build: sanitize-images
    ./utils/make_imagesets.py
    latexmk -pdf book.tex

clean:
    latexmk -c

clean-all:
    latexmk -C
    rm book_no_boxes.pdf
    
# Some printing services do not handle PDF boxes properly; use this command to make all boxes the same
strip-pdf-boxes:
    ./utils/strip_pdf_boxes.py book.pdf book_no_boxes.pdf
