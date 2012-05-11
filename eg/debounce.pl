# NOTE: this is NOT the example at:
# http://arduino.cc/en/Tutorial/Debounce
# because that is broken :-)
# 
# this code is taken from:
# http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1279083116

use Arduino::Pseudo;

my $arduino = Arduino::Pseudo->new();

my $buttonPin = 2;
my $ledPin = 13;

$arduino->connect( $buttonPin => 'button',
    pos => [ 30, 10 ],
    label => 'click me!',
);

$arduino->connect( $ledPin => 'led',
    pos => [ 10, 10 ],
    color => 'red',
);

my $ledState = $arduino->LOW;
my $lastButtonState = $arduino->LOW;
my $lastReading = $arduino->LOW;

my $lastDebounceTime = 0;
my $debounceDelay = 50;

$arduino->MainLoop;

sub loop {
    my($arduino) = @_;
    my $reading = $arduino->digitalRead($buttonPin);
    if($reading != $lastReading) {        
        $lastDebounceTime = $arduino->millis();        
        $lastReading = $reading;
    }
    if(($arduino->millis() - $lastDebounceTime) > $debounceDelay) {
        if($lastButtonState == $arduino->LOW 
        && $reading == $arduino->HIGH) {
            $ledState = !$ledState;
            $arduino->digitalWrite($ledPin, $ledState);
        }        
        $lastButtonState = $reading;
    }
}

