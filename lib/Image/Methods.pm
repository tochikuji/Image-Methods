package Image::Methods;

use 5.008005;
use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK = qw/grayscale grayscale_means grayscale_ow grayscale_basic binarization/;
our $VERSION = "0.02";

sub new{
    my $package = shift;

    my $self = {
        bitmap => [],
    };

    return bless $self, $package;
}


sub grayscale_means{
    my $bitmap = shift;
    my $bmax = shift;
    $bmax //= 255;

    my $gmap = [];
    my ($width, $height) = ($#{$bitmap->[0]}, $#$bitmap);

    for my $y (0 .. $height){
        for my $x (0 .. $width){
            $gmap->[$y]->[$x] = int(($bitmap->[$y]->[$x]->[0] + $bitmap->[$y]->[$x]->[1] + $bitmap->[$y]->[$x]->[2]) * 255 / $bmax / 3);
        }
    }

    return $gmap;
}


sub grayscale_basic{
    my $bitmap = shift;
    my $bmax = shift;
    $bmax //= 255;

    my $gmap = [];
    my ($width, $height) = ($#{$bitmap->[0]}, $#$bitmap);

    for my $y (0 .. $height){
        for my $x (0 .. $width){
            $gmap->[$y]->[$x] = int(($bitmap->[$y]->[$x]->[0] * 0.299 + $bitmap->[$y]->[$x]->[1] * 0.587 + $bitmap->[$y]->[$x]->[2] * 0.114) * 255 / $bmax);
        }
    }
    
    return $gmap;
}


sub grayscale_ow{
    my $bitmap = shift;
    my ($r, $g, $b, $bmax) = @_;

    $bmax //= 255;

    # normalize
    my $sum = $r + $g + $b;
    $r /= $sum; $g /= $sum; $b /= $sum;

    my $gmap = [];
    my ($width, $height) = ($#{$bitmap->[0]}, $#$bitmap);

    for my $y (0 .. $height){
        for my $x (0 .. $width){
            $gmap->[$y]->[$x] = int(($bitmap->[$y]->[$x]->[0] * $r + $bitmap->[$y]->[$x]->[1] * $g + $bitmap->[$y]->[$x]->[2] * $b) * 255 / $bmax);
        }
    }
    
    return $gmap;
}



sub grayscale{
    my $bitmap = shift;
    my $bmax = shift;

    return grayscale_basic($bitmap, $bmax);
}


sub binarization{
    my $gmap = shift;
    my $bmax = shift;
    $bmax //= 255;

    my $bitmap = [];
    my ($width, $height) = ($#{$gmap->[0]}, $#$gmap);

    for my $y (0 .. $height){
        for my $x (0 .. $width){
            push @$bitmap, $gmap->[$y]->[$x];
        }
    }

    my @histgram;
    for( 0..$bmax ){ $histgram[$_]+=0 }     # avoid undef warn

    for( @$bitmap ){
        ++$histgram[$_];
    }
    
    my ( $max, $min ) = @{min_max( \@histgram, $bmax)};

    my $thr;
    my $i = 0;
    my $j = scalar( @$bitmap );
    my ($st0, $st1, $t0, $t1) = (0, 0, 0, 0);
    my $cratio = 0;
    for( my $k = $min;$k <= $max;++$k ){
        $st1 += $k * $histgram[$k];
        $t1 += $k * $k * $histgram[$k];
    }

    for( $thr = $min - 1; $thr <= $max; ++$thr ){
        last if $thr == $max;
        next if $histgram[$thr] == 0;

        my $m0 = $histgram[$thr];
        my $m1 = $m0 * $thr;
        my $m2 = $m1 * $thr;

        $i += $m0; $st0 += $m1; $t0 += $m2;
        $j -= $m0; $st1 -= $m1; $t1 -= $m2;

        my $mean0 = $st0 / $i;
        my $mean1 = $st1 / $j;
        my $var0 = ($t0 / $i) - $mean0 * $mean0;
        my $var1 = ($t1 / $j) - $mean1 * $mean1;

        my $vbc = $i * $j * ($mean0 - $mean1) ** 2;
        my $voc = $i * $var0 + $j * $var1;

        do{ $thr = int( $bmax / 2 ); last; } if $voc == 0;
        my $cration =  $vbc / $voc;

        last if $cration < $cratio;
        $cratio = $cration;
    }

    my @binmap = map{ $_ > $thr ? 0 : 1 } @$bitmap;

    my $res;
    for my $y (0 .. $height){
        for my $x (0 .. $width){
            $res->[$y]->[$x] = @binmap[$x + $y * ($width + 1)];
        }
    }

    return $res;
}


sub min_max($$){
    my $histgram = shift;
    my $bmax = shift;

    my ($min, $max);

    for( my $i = $bmax;$i >= 0;--$i ){
        $min = $i if $histgram->[$i] != 0;
    }
    for( my $i = 0;$i <= $bmax;++$i ){
        $max = $i if $histgram->[$i] != 0;
    }

    return [$max, $min];
}


1;
__END__
