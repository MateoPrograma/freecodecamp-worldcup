#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Limpiar las tablas para empezar de cero cada vez que corramos el script
echo $($PSQL "TRUNCATE TABLE games, teams")

# Leer el archivo línea por línea separados por comas
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Evitar que lea la primera fila que dice "year,round,winner..."
  if [[ $YEAR != "year" ]]
  then
    # --- 1. PROCESAR EL EQUIPO GANADOR ---
    # Buscar si el ganador ya está en la tabla
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # Si no está (la variable está vacía), lo insertamos
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      # Volvemos a buscar su ID generado
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # --- 2. PROCESAR EL EQUIPO OPONENTE ---
    # Buscar si el oponente ya está en la tabla
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    
    # Si no está, lo insertamos
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      # Volvemos a buscar su ID generado
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # --- 3. INSERTAR EL PARTIDO ---
    # Ahora que tenemos los IDs de los dos equipos, guardamos el partido
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done