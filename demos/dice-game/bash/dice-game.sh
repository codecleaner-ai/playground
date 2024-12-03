#!/bin/bash

roll_dice() {
    echo $((RANDOM % 6 + 1))
}

play_game() {
    total_score=0
    for i in {1..10}; do
        dice1=$(roll_dice)
        dice2=$(roll_dice)
        score=$((dice1 + dice2))
        if [ $dice1 -eq $dice2 ]; then
            score=$((score * 2))
        fi
        total_score=$((total_score + score))
    done
    echo $total_score
}

main() {
    player1_score=$(play_game)
    player2_score=$(play_game)

    if [ $player1_score -gt $player2_score ]; then
        echo "Player 1 wins with $player1_score points"
    elif [ $player2_score -gt $player1_score ]; then
        echo "Player 2 wins with $player2_score points"
    else
        echo "It's a tie with $player1_score points each"
    fi
}

main
