function rollDice(): number {
    return Math.floor(Math.random() * 6) + 1;
}

function playGame(): number {
    let totalScore = 0;
    for (let i = 0; i < 10; i++) {
        const dice1 = rollDice();
        const dice2 = rollDice();
        let score = dice1 + dice2;
        if (dice1 === dice2) {
            score *= 2;
        }
        totalScore += score;
    }
    return totalScore;
}

function main(): void {
    const player1Score = playGame();
    const player2Score = playGame();

    if (player1Score > player2Score) {
        console.log(`Player 1 wins with ${player1Score} points`);
    } else if (player2Score > player1Score) {
        console.log(`Player 2 wins with ${player2Score} points`);
    } else {
        console.log(`It's a tie with ${player1Score} points each`);
    }
}

main();
