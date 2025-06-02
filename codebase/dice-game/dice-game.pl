#!/usr/bin/perl
use strict;
use warnings;
use List::Util 'sum';

sub roll_dice {
    return int(rand(6)) + 1;
}

sub play_game {
    my $total_score = 0;
    for my $i (1..10) {
        my $dice1 = roll_dice();
        my $dice2 = roll_dice();
        my $score = $dice1 + $dice2;
        if ($dice1 == $dice2) {
            $score *= 2;
        }
        $total_score += $score;
    }
    return $total_score;
}

sub main {
    my $player1_score = play_game();
    my $player2_score = play_game();

    if ($player1_score > $player2_score) {
        print "Player 1 wins with $player1_score points\n";
    } elsif ($player2_score > $player1_score) {
        print "Player 2 wins with $player2_score points\n";
    } else {
        print "It's a tie with $player1_score points each\n";
    }
}

main();
