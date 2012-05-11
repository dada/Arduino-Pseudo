package Arduino::Pseudo;

# ABSTRACT: Write Arduino pseudocode in Perl

=head1 NAME

Arduino::Pseudo - Write Arduino pseudocode in Perl

=head1 SYNOPSIS

    use Arduino::Pseudo;

    my $led = 13;

    my $arduino = Arduino::Pseudo->new();

    $arduino->connect( $led => 'led',
        pos => [ 10, 10 ],
        color => 'red',
    );

    $arduino->MainLoop;

    sub loop {
        my($arduino) = @_;
        $arduino->digitalWrite($led, $arduino->HIGH);
        $arduino->delay(1000);
        $arduino->digitalWrite($led, $arduino->LOW);
        $arduino->delay(1000);
    }

=head1 DESCRIPTION

Arduino::Pseudo is a Perl module that mimics the working of an Arduino board. 
It is intended to do rapid prototyping of Arduino code, before building a physical circuit.

Please mind what Arduino::Pseudo is B<NOT>:

=over 4

=item *

It is B<not an Arduino emulator>, it doesn't even try. 
The code is plain Perl, it just "resembles" Arduino code. 

=item *

It is B<not an electrical circuit simulator>. The abstraction is as simplified as possible, 
no voltage, no resistors, nothing. Just an Arduino::Pseudo object to which you can connect 
equally abstract components.

=back

If you need something more "true to the hardware" (or simply something more serious :-))
than this module, there are some interesting links in the L<SEE ALSO> section.

Again, the purpose of this module is to do rapid prototyping: in other words, see how
your code would I<probably> run on a real Arduino board. The code just implements a subset
of the Arduino standard library. If something is not mentioned in this documentation, is
B<not supported>.

At the very heart, Arduino::Pseudo is just a L<Wx::App> with an (empty) GUI.
The (pseudo) components you connect to it will appear on the GUI in form of buttons,
labels, sliders, etc. so that you can interact with them.

Arduino::Pseudo expects a sub named C<loop> to exists in your main namespace, and it
will C<die> if such sub is not found. That's the equivalent of an Arduino 
C<void loop() { ... }> function.

Also note that Arduino::Pseudo uses a Timer with a 1-millisecond delay, so 1 millisecond
is the minimum resolution you can get. If you need higher time resolution, then this
tool is not for you.

=cut

use 5.010;
use warnings;
use strict;

use Moose;
use MooseX::NonMoose;

use Wx;
extends 'Wx::App';

use Wx::Event qw( 
    EVT_BUTTON EVT_TIMER EVT_SLIDER
    EVT_LEFT_DOWN EVT_LEFT_UP
    EVT_SIZE
);

use Arduino::Pseudo::PushButton;
use Arduino::Pseudo::LED;
use Arduino::Pseudo::Potentiometer;
use Arduino::Pseudo::LCD;

use Time::HiRes qw( time sleep );

use Exporter;
our @EXPORT = qw/ HIGH LOW /;

our $VERSION = '0.001';

has _frame => (
    is => 'rw',
    isa => 'Wx::Frame',
);

has _panel => (
    is => 'rw',
    isa => 'Wx::Panel',
);

has _timer => (
    is => 'rw',
    isa => 'Wx::Timer',    
);

has _pin => (
    is => 'ro',
    isa => 'HashRef',
    default => sub {
        my %pin;
        $pin{$_} = 1 for 0..13;
        $pin{$_} = 0 for 14..19;
        return \%pin;
    },
);

has _things => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { return {}; },
);

has _start => (
    is => 'rw',
    isa => 'Num',
    default => 0,
);

sub OnInit {
    my($self) = @_;

    $self->_frame(
        Wx::Frame->new(
            undef, -1, "Arduino::Pseudo " . $self->VERSION,
        )
    );

    $self->_panel(
        Wx::Panel->new(
            $self->_frame, -1,
        )
    );
    
    $self->_timer(
        Wx::Timer->new(
            $self->_frame, -1,
        )
    );
    EVT_TIMER( $self, $self->_timer, \&_loop );

    # my($width, $height) = $self->_frame->GetSizeWH();
    # $self->_width = $width;
    # $self->_height = $height;    
    # $self->_body = Wx::Panel->new( 
    #     $self->_frame, -1, [ 20, 200 ], [ $width-40, 100 ] 
    # );
    # $self->_body->SetBackgroundColour(Wx::Colour->new("#0F7391"));

    $self->_frame->Show();
    $self->_start( time() );
    $self->_timer->Start( 1, 0);
    
    return 1;
}

sub OnExit {
    my($self) = @_;
    $self->ExitMainLoop();
}

=head1 METHODS

=head2 connect $pin => $thing, %params

Connect $thing to Arduino::Pseudo pin $pin. Currently recognized things
are:

=over 4

=item button

See L<Arduino::Pseudo::PushButton>.

=item pot

See L<Arduino::Pseudo::Potentiometer>.

=item led

See L<Arduino::Pseudo::LED>.

=item lcd

See L<Arduino::Pseudo::LCD>.

=back

=cut

sub connect {
    my($self, $pin, $thing, %params) = @_;
    
    my $object;
    
    given($thing) {
        when('button') {
            $object = Arduino::Pseudo::PushButton->new(
                arduino => $self,
                parent => $self->_panel,
                pin => $pin,
                %params,
            );
        }
        when('pot') {
            $object = Arduino::Pseudo::Potentiometer->new(
                arduino => $self,
                parent => $self->_panel,
                pin => $pin,
                %params,
            );
        }
        when('lcd') {
            $object = Arduino::Pseudo::LCD->new(
                arduino => $self,
                parent => $self->_panel,
                pin => $pin,
                %params,
            );            
        }
        when('led') {
            $object = Arduino::Pseudo::LED->new(
                arduino => $self,
                parent => $self->_panel,
                pin => $pin,
                %params,
            );
        }
    }
    if(defined $object) {
        $self->_things->{$pin} = $object;
        return $object;
    }
    
}

=head2 log $message

Prints a logline on STDOUT, prepended with the milliseconds
from simulation start.

=cut

sub log {
    my($self, $message) = @_;
    say sprintf("[%12s] %s", $self->millis, $message);
}

sub _loop {
    my($self) = @_;
    die "you did not define sub loop!" unless main::->can('loop');
    main::loop($self);
}

=head1 ARDUINO METHODS

The following methods are supposed to be as equivalent as possible to
the homonymous Arduino functions.

=head2 LOW

See L<http://arduino.cc/en/Reference/Constants>.

=cut

sub LOW { 0; }

=head2 HIGH

See L<http://arduino.cc/en/Reference/Constants>.

=cut

sub HIGH { 1; }

=head2 digitalRead $pin

See L<http://arduino.cc/en/Reference/DigitalRead>.

=cut

sub digitalRead {
    my($self, $pinNumber) = @_;
    return $self->_pin->{$pinNumber};
}

=head2 digitalWrite $pin, $value

See L<http://arduino.cc/en/Reference/DigitalWrite>.

=cut

sub digitalWrite {
    my($self, $pinNumber, $value) = @_;
    $self->_pin->{$pinNumber} = $value;
    if(defined $self->_things->{$pinNumber}) {
        given($self->_things->{$pinNumber}) {
            when($_->isa('Arduino::Pseudo::LED')) {
                if($value == HIGH()) {
                    $_->on();
                } else {
                    $_->off();
                }
            }
        }
    }
}

=head2 analogRead $pin

See L<http://arduino.cc/en/Reference/AnalogRead>.

=cut

sub analogRead {
    my($self, $pinNumber) = @_;
    # say "analogRead($pinNumber)=" . $self->_pin->{$pinNumber};
    return $self->_pin->{$pinNumber};
}

=head2 map $value, $from_min, $from_max, $to_min, $to_max

See L<http://arduino.cc/en/Reference/Map>.

=cut

sub map {
    my($self, $value, $from_min, $from_max, $to_min, $to_max) = @_;   
    return int(
        ($value - $from_min) * ($to_max - $to_min) / ($from_max - $from_min) + $to_min
    );
}

=head2 millis

See L<http://arduino.cc/en/Reference/Millis>.

=cut

sub millis {
    my($self) = @_;
    my $r = int((time() - $self->_start) * 1000);
    return $r;
}

=head2 delay $value

See L<http://arduino.cc/en/Reference/Delay>.

=cut

sub delay {
    my($self, $value) = @_;
    my $end = $self->millis + $value;
    while($self->millis < $end) {
        $self->Dispatch() if $self->Pending();
        sleep 0.001;
    }
}

=head2 tone $pin, $value, $length

See L<http://arduino.cc/en/Reference/Tone>.

=cut

sub tone {
    my($self, $pin, $value, $length) = @_;
    $self->log("PLAYING TONE($value) ON PIN $pin");
}

=head1 SEE ALSO

L<http://www.arduino.cc/> - Arduino website

L<http://www.virtualbreadboard.net/> - Real Arduino emulator (commercial)

L<http://emulare.sourceforge.net/> - General purpose hardware emulator (open source)

L<http://en.wikipedia.org/wiki/SPICE> - General-purpose, open source analog electronic circuit simulator

=head1 AUTHOR

Aldo Calpini <dada@perl.it>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Aldo Calpini.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

no Moose;
"Oscillate Wildly";
