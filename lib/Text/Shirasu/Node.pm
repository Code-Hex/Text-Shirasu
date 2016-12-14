package Text::Shirasu::Node;

sub id      { $_[0]->{id}      }
sub surface { $_[0]->{surface} }
sub feature { $_[0]->{feature} }
sub length  { $_[0]->{length}  }
sub rlength { $_[0]->{rlength} }
sub lcattr  { $_[0]->{lcattr}  }
sub stat    { $_[0]->{stat}    }
sub isbest  { $_[0]->{isbest}  }
sub alpha   { $_[0]->{alpha}   }
sub beta    { $_[0]->{beta}    }
sub prob    { $_[0]->{prob}    }
sub wcost   { $_[0]->{wcost}   }
sub cost    { $_[0]->{cost}    }

1;