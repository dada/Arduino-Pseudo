package Arduino::Pseudo::Potentiometer;

# ABSTRACT: Pseudo potentiometer object for Arduino::Pseudo

=head1 NAME

Arduino::Pseudo::Potentiometer - Pseudo potentiometer object for Arduino::Pseudo

=head1 SYNOPSIS

    $arduino->connect( 1 => 'pot', label => 'volume' );
    
=head1 DESCRIPTION

A simple potentiometer object. In reality, this can (and should) be 
used as a generic analog input, to simulate eg. potentiometers, 
trimmers, sensors, etc.

The UI is implemented as a Wx::Slider.

=cut

use 5.010;
use warnings;
use strict;

use Moose;
use MooseX::NonMoose;

use Wx;

use Wx::Event qw( EVT_SLIDER );

with 'Arduino::Pseudo::Thing';

has label => (
    is => 'rw',
    isa => 'Str',
);

has _slider => (
    is => 'rw',
    isa => 'Wx::Slider',
);

has _statictext => (
    is => 'rw',
    isa => 'Wx::StaticText',
);

sub FOREIGNBUILDARGS {
    my($class, %args) = @_;

}

sub BUILD {
    my($self) = @_;
    $self->_slider(
        Wx::Slider->new(
            $self->parent, 
            $self->pin,
            0, 0, 1023,
            $self->pos,
            [100, 50],
        )
    );
    $self->_slider->SetRange(0, 1023);
    EVT_SLIDER( $self->arduino, $self->_slider, \&OnSlide );
    $self->arduino->digitalWrite($self->pin, 0);

    my @label_pos = @{ $self->pos };
    $label_pos[1] -= 4;
    
    $self->_statictext(
        Wx::StaticText->new(
            $self->parent,
            $self->pin + 1000,
            $self->label,
            \@label_pos,
            [ -1, -1 ],
        )
    );

}

sub OnSlide {
    my($arduino, $event) = @_;
    my $pot = $event->GetEventObject();
    my $pin = $pot->GetId();
    my $value = $pot->GetValue();
    $arduino->digitalWrite($pin, $value);    
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
