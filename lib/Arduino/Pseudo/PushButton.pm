package Arduino::Pseudo::PushButton;

# ABSTRACT: pseudo push button object for Arduino::Pseudo

=head1 NAME

Arduino::Pseudo::PushButton - Pseudo push button object for Arduino::Pseudo

=head1 SYNOPSIS

    $arduino->connect( 1 => 'button', label => 'click me!');
    
=head1 DESCRIPTION

A simple push button object.

=cut

use 5.010;
use warnings;
use strict;

use Moose;
use MooseX::NonMoose;

use Wx;
extends 'Wx::Button';

use Wx::Event qw( EVT_LEFT_DOWN EVT_LEFT_UP );

with 'Arduino::Pseudo::Thing';

=head1 ATTRIBUTES

=head2 label

Text to appear on the button.

=cut

has label => (
    is => 'rw',
    isa => 'Str',
    default => '',
);

=head2 inverted

By default a button will send to Arduino HIGH when pushed, LOW when 
released. Specify inverted => 1 if you want this behaviour reversed.

=cut

has inverted => (
    is => 'rw',
    isa => 'Bool',
    default => 0,
);
    
sub FOREIGNBUILDARGS {
    my($class, %args) = @_;

    $args{pos} = [ -1, -1 ] unless defined $args{pos};

    return (
        $args{parent},
        $args{pin},
        $args{label},
        $args{pos},
        [ -1, -1 ],
    );
}

sub BUILD {
    my($self) = @_;
    EVT_LEFT_DOWN($self, \&OnMouseDown);
    EVT_LEFT_UP($self, \&OnMouseUp);
    # call OnMouseUp so that an inverted button is HIGH per default
    $self->OnMouseUp(undef);
}

sub OnInit {
    my($self) = @_;
}

sub OnMouseDown {
    my($self, $event) = @_;
    $self->arduino->digitalWrite(
        $self->pin, 
        $self->inverted 
            ? $self->arduino->LOW
            : $self->arduino->HIGH
    );
    $event->Skip(1) if defined $event;
}

sub OnMouseUp {
    my($self, $event) = @_;
    $self->arduino->digitalWrite(
        $self->pin, 
        $self->inverted 
            ? $self->arduino->HIGH
            : $self->arduino->LOW
    );
    $event->Skip(1) if defined $event;
}

no Moose;
"Oscillate Wildly";
