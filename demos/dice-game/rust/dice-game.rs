use rand::Rng;

fn roll_dice() -> i32 {
    let mut rng = rand::thread_rng();
    rng.gen_range(1..=6)
}

fn play_game() -> i32 {
    let mut total_score = 0;
    for _ in 0..10 {
        let dice1 = roll_dice();
        let dice2 = roll_dice();
        let mut score = dice1 + dice2;
        if dice1 == dice2 {
            score *= 2;
        }
        total_score += score;
    }
    total_score
}

fn main() {
    let player1_score = play_game();
    let player2_score = play_game();

    if player1_score > player2_score {
        println!("Player 1 wins with {} points", player1_score);
    } else if player2_score > player1_score {
        println!("Player 2 wins with {} points", player2_score);
    } else {
        println!("It's a tie with {} points each", player1_score);
    }
}
