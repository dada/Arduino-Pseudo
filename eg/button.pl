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

my $buttonState = $arduino->LOW;

$arduino->MainLoop;

sub loop {
    my($arduino) = @_;
    $buttonState = $arduino->digitalRead($buttonPin);
    if($buttonState == $arduino->HIGH) {
        $arduino->digitalWrite($ledPin, $arduino->HIGH);
    }
    else {
        $arduino->digitalWrite($ledPin, $arduino->LOW);
    }
}

