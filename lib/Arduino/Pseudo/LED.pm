package Arduino::Pseudo::LED;

# ABSTRACT: pseudo LED object for Arduino::Pseudo

=head1 NAME

Arduino::Pseudo::LED - Pseudo LED object for Arduino::Pseudo

=head1 SYNOPSIS

    $arduino->connect( 13 => 'led', color => 'red');
    
=head1 DESCRIPTION

A simple LED which goes on or off if the connected pin goes,
respectively, HIGH or LOW.

The "led" UI is implemented as a read-only 16x16 Wx::TextCtrl with
thin border.

=cut

use 5.010;
use warnings;
use strict;

use Moose;
use MooseX::NonMoose;

use Wx qw(
    wxDEFAULT wxNORMAL wxTE_READONLY wxBORDER_SIMPLE
);
extends 'Wx::TextCtrl';

with 'Arduino::Pseudo::Thing';

=head1 ATTRIBUTES

=head2 color

The color name for the LED. Use any string suitable for 
Wx::Colour constructor. Default is 'red'.

=cut

has color => (
    is => 'rw',
    isa => 'Str',
    default => 'red',
);

has color_off => (
    is => 'rw',
    isa => 'Wx::Colour',
    lazy_build => 1,    
);

sub _build_color_off {
    my($self) = @_;    
    $self->color_off( Wx::Colour->new('gray') );
}    

has color_on => (
    is => 'rw',
    isa => 'Wx::Colour',
    lazy_build => 1,
);

sub _build_color_on {
    my($self) = @_;
    $self->color_on( Wx::Colour->new($self->color) );
}

sub FOREIGNBUILDARGS {
    my($class, %args) = @_;

    $args{pos} = [-1, -1] unless defined $args{pos};

    return (
        $args{parent},
        $args{pin},
        " ",
        $args{pos},
        [ 16, 16 ],
    );
}

sub BUILD {
    my($self) = @_;

    $self->SetWindowStyle(
        wxTE_READONLY | wxBORDER_SIMPLE,
    );
    $self->SetBackgroundColour( $self->color_off );
}

=head1 METHODS

You shouldn't need to call those, Arduino::Pseudo does this for you.

=head2 on

Turns the LED on.

=cut

sub on {
    my($self) = @_;    
    $self->SetBackgroundColour( $self->color_on );
    $self->Refresh();
    $self->Update();
}

=head2 off

Turns the LED off.

=cut

sub off {
    my($self) = @_;    
    $self->SetBackgroundColour( $self->color_off );
    $self->Refresh();
    $self->Update();
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
