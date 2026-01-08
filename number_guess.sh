#!/bin/bash

# Number Guessing Game Script

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"

$PSQL "CREATE TABLE IF NOT EXISTS users(username VARCHAR(22) PRIMARY KEY, games_played INT DEFAULT 0, best_game INT);"

echo "Enter your username:"
read USERNAME

USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

if [[ -z $USER_INFO ]]; then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
else
  IFS='|' read GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET=$(( RANDOM % 1000 + 1 ))
GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
  ((GUESS_COUNT++))
  if (( GUESS > SECRET )); then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET )); then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $SECRET. Nice job!"
    break
  fi
done

if [[ $GAMES_PLAYED -eq 0 ]]; then
  $PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 1, $GUESS_COUNT);"
else
  NEW_GAMES=$((GAMES_PLAYED + 1))
  if [[ -z $BEST_GAME ]] || (( GUESS_COUNT < BEST_GAME )); then
    NEW_BEST=$GUESS_COUNT
  else
    NEW_BEST=$BEST_GAME
  fi
  $PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$NEW_BEST WHERE username='$USERNAME';"
fi
