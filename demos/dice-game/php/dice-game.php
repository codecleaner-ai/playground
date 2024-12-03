<?php

function roll_dice() {
    return rand(1, 6);
}

function play_game() {
    $total_score = 0;
    for ($i = 0; $i < 10; $i++) {
        $dice1 = roll_dice();
        $dice2 = roll_dice();
        $score = $dice1 + $dice2;
        if ($dice1 == $dice2) {
            $score *= 2;
        }
        $total_score += $score;
    }
    return $total_score;
}

function main() {
    $player1_score = play_game();
    $player2_score = play_game();

    if ($player1_score > $player2_score) {
        echo "Player 1 wins with $player1_score points\n";
    } elseif ($player2_score > $player1_score) {
        echo "Player 2 wins with $player2_score points\n";
    } else {
        echo "It's a tie with $player1_score points each\n";
    }
}

main();

?>
