package Arduino::Pseudo::Thing;

# ABSTRACT: Base role for Arduino::Pseudo things

=head1 NAME

Arduino::Pseudo::Thing - Base role for Arduino::Pseudo things

=head1 DESCRIPTION

Just a role implemented by Arduino::Pseudo submodules.

=head1 ATTRIBUTES

=cut

use 5.010;
use warnings;
use strict;

use Moose::Role;
use namespace::autoclean;

=head2 arduino

A reference to the containing Arduino::Pseudo object.

=cut

has arduino => (
    is => 'ro',
    isa => 'Arduino::Pseudo',
    required => 1,
);

=head2 parent

The Wx::Frame object on which UI widgets are created.

=cut

has parent => (
    is => 'ro',
    isa => 'Wx::Panel',
    required => 1,
);

=head2 pin

The pin number this thing is connected to.

=cut

has pin => (
    is => 'rw',
    isa => 'Int',
    required => 1,
);

=head2 pos

The position on parent where UI widgets are created.

=cut

has pos => (
    is => 'rw',
    isa => 'Maybe[ArrayRef]',
    default => sub { [ -1, -1 ] },
);

=head1 AUTHOR

Aldo Calpini <dada@perl.it>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Aldo Calpini.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

no Moose;
"Oscillate Wildly";
