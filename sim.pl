#!perl
# sim.pl: Simulate dice-based combat outcomes

use 5.014;
use strict;
use warnings;

use Games::Dice 'roll';
use Getopt::Args;
#use Path::Class;

# Parse command-line options
use constant DIE_COMMENT => 'XdY[+-*/b]Z - X=dice, Y=sides, Z=modifier (see Games::Dice)';

arg player_roll => (
    isa => 'Str',
    comment => DIE_COMMENT,
    required => 1,
);

arg enemy_roll => (
    isa => 'Str',
    comment => 'as PLAYER_ROLL',
    required => 1,
);

arg num_trials => (
    isa => 'Int',
    comment => 'Default 1000',
    default => 1000,
);

opt player_wins => (
    isa => 'Str',
    alias => 'e',
    comment => 'Perl code that gets rolls in $player and $enemy, and returns true if the player wins.  Wrap in a do {} if complex.',
    default => '($player >= $enemy)',
);

my $args = optargs;

# Criterion for whether the player won.  By default, the player wins on a roll
# equal to or higher than the enemy's.  Called as
# $did_player_win->($player_roll, $enemy_roll).

my $did_player_win = eval qq[
    sub {
        my (\$player, \$enemy) = \@_;
        $args->{player_wins}
    };
] or die "Couldn't evaluate -e argument: $@";

my $number_player_won = 0;

for(my $idx=0; $idx < $args->{num_trials}; ++$idx) {
    my $player = roll($args->{player_roll});
    my $enemy = roll($args->{enemy_roll});
    ++$number_player_won if $did_player_win->($player, $enemy);
}

printf("Player won %f percent of %d trials\n",
    $number_player_won / $args->{num_trials},
    $args->{num_trials}
);

__END__

=head1 NAME

sim.pl - Simulate dice-based combat outcomes

=head1 SYNOPSIS

    sim.pl <player die roll> <enemy die roll> [number of trials]

The rolls are specified in the format of inputs for L<Games::Dice>.
The number of trials is optional and defaults to 1000.

=cut

# vi: set fdm=marker: #
