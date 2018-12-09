#!/usr/bin/env python3

# 459 players; last marble is worth 72103 points

def play_marble(players, last_marble):
    current = 0
    circle = [0]
    scores = dict((i, 0) for i in range(0, players))
    player = 0
    # print(circle)
    for next_marble in range(1, last_marble + 1):
        if next_marble % 23 == 0:
            current = (len(circle) + current - 6) % len(circle)
            take = circle.pop(current)
            current -= 1 # compensate for marble taken
            print('Taking', current, player, scores[player], next_marble, take)
            scores[player] = scores[player] + next_marble + take
        else:
            current = (current + 2) % len(circle)
            circle.insert(current + 1, next_marble)
            # print(player, circle)
        player = (player + 1) % players

    return max(scores.values())

assert play_marble(9, 50) == 32
assert play_marble(10, 1618) == 8317
assert play_marble(13, 7999) == 146373
assert play_marble(17, 1104) == 2764
assert play_marble(21, 6111) == 54718
print("Part One:", play_marble(459, 72103))
# print("Part Two:", play_marble(459, 72103 * 100))
