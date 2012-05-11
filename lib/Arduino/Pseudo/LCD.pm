package Arduino::Pseudo::LCD;

# ABSTRACT: Pseudo LCD module object for Arduino::Pseudo

=head1 NAME

Arduino::Pseudo::LCD - Pseudo LCD module object for Arduino::Pseudo

=head1 SYNOPSIS

    my $lcd = $arduino->connect( 8 => 'lcd', cols => 16, rows => 2 );
    $lcd->print("hello, world!");

=head1 DESCRIPTION

A simple LCD module object, assuming HD44780-compatible, eg.
LiquidCrystal-compatible
(see L<http://arduino.cc/en/Reference/LiquidCrystal>).

B<WARNING>: the pin connection is purely fictitious. In real life,
an LCD module requires 6 pins!

Note also that only a minimal subset of the LiquidCrystal library
and/or LCD behaviour is implemented. In particular:

=over 4

=item *

there is no support for createChar(), autoscroll(), blink() etc.
See the L<METHODS> section for supported methods.

=item *

the pseudo LCD does not "overflow" like a real one.
That is, if you try to print more characters than a line holds, the
text is simply truncated. In real life, line 1 overflows on line 3
and so on.

=back

The UI is implemented with an array of C<cols> x C<rows> Wx::TextCtrl,
with green background and no border, and text is written using a
Courier type (monospaced) font.

=cut

use 5.010;
use warnings;
use strict;

use Moose;
use MooseX::NonMoose;

use Wx qw(
    wxDEFAULT wxNORMAL wxTE_READONLY wxBORDER_NONE
);

with 'Arduino::Pseudo::Thing';

=head1 ATTRIBUTES

=head2 cols

Number of columns. Default is 16.

=cut

has cols => (
    is => 'rw',
    isa => 'Int',
    default => 16,
);

=head2 rows

Number of rows. Default is 2.

=cut

has rows => (
    is => 'rw',
    isa => 'Int',
    default => 2,
);

=head2 X

Current X position (eg. column) of the cursor.

=cut

has X => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

=head2 Y

Current Y position (eg. row) of the cursor.

=cut

has Y => (
    is => 'rw',
    isa => 'Int',
    default => 0,
);

=head2 content

The current LCD content. An array of strings (one for each row).

=cut

has content => (
    is => 'rw',
    isa => 'ArrayRef[Str]',
    lazy_build => 1,
);

sub _build_content {
    my($self) = @_;
    return [ ( " " x $self->cols ) x $self->rows ];
}

has _controls => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

sub BUILD {
    my($self) = @_;

    my $monospace = Wx::Font->new(12, wxDEFAULT, wxNORMAL, wxNORMAL, 0, "Courier");

    my $px = $self->pos->[0];
    foreach my $x (1..$self->cols) {
        my $py = $self->pos->[1];
        foreach my $y (1..$self->rows) {
            my $id = 1_000_000 + $y * 1_000 + $x;
            my $control = Wx::TextCtrl->new(
                $self->parent, $id, " ", [ $px, $py ], [12, 16],
                wxTE_READONLY | wxBORDER_NONE,
            );
            $control->SetFont($monospace);
            $control->SetBackgroundColour(Wx::Colour->new('green'));
            $self->_controls->{$id} = $control;
            $py += 17;
        }
        $px += 13;
    }
}

=head1 METHODS

=head2 setCursor $x, $y

See L<http://arduino.cc/en/Reference/LiquidCrystalSetCursor>.

=cut

sub setCursor {
    my($self, $x, $y) = @_;
    $self->X($x);
    $self->Y($y);
}

=head2 print $string

See L<http://arduino.cc/en/Reference/LiquidCrystalPrint>. The BASE
argument is not implemented.

=cut

sub print {
    my($self, $string) = @_;

    substr(
        $self->content->[$self->Y], $self->X,
        length($string), $string
    );

    for my $x (1..$self->cols) {
        for my $y (1..$self->rows) {
            my $id = 1_000_000 + $y * 1_000 + $x;
            my $char = substr($self->content->[$y-1], $x-1, 1);
            $self->_controls->{$id}->SetValue($char);
        }
    }
}


=head2 home

See L<http://arduino.cc/en/Reference/LiquidCrystalHome>.

=cut

sub home {
    my($self) = @_;
    $self->X(0);
    $self->Y(0);
}

=head2 clear

See L<http://arduino.cc/en/Reference/LiquidCrystalClear>.

=cut

sub clear {
    my($self) = @_;
    $_ = ( " " x $self->cols ) foreach @{ $self->content };
    $self->home();
}



=head1 AUTHOR

Aldo Calpini <dada@perl.it>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Aldo Calpini.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

no Moose;
"Oscillate Wildly";
