# NAME

Image::Methods - Some general functions for image maps

# SYNOPSIS

    use Image::Methods qw/binarization grayscale grayscale_means grayscale_basic/;
    use Image::PNM qw/load_pnm/;

    my $bitmap = load_pnm('image.ppm')  # color maps
    my $gray = grayscale($gray);    # grayscale($gray, 255)
    # or grayscale($img->bitmap, $img->bmax) if you use from Image::PNM instance
    # grayscale_basic is same as grayscale

    my $binarymap = binarization($gray);

# DESCRIPTION

Image::Methods is my adversaria

# LICENSE

Copyright (C) Aiga Suzuki.

This library is released under MIT licence.

# AUTHOR

Aiga Suzuki 
