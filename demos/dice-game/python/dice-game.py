import random

def roll_dice():
    return random.randint(1, 6)

def play_game():
    total_score = 0
    for _ in range(10):
        dice1 = roll_dice()
        dice2 = roll_dice()
        score = dice1 + dice2
        if dice1 == dice2:
            score *= 2
        total_score += score
    return total_score

def main():
    player1_score = play_game()
    player2_score = play_game()
    
    if player1_score > player2_score:
        print("Player 1 wins with", player1_score, "points")
    elif player2_score > player1_score:
        print("Player 2 wins with", player2_score, "points")
    else:
        print("It's a tie with", player1_score, "points each")

if __name__ == "__main__":
    main()