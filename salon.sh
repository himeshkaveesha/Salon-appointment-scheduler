#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ -z $1 ]]
  then
    echo -e "\nWelcome to My Salon, how can I help you?\n"
  else
    echo -e "\n$1"
  fi

  $PSQL "SELECT service_id, name FROM services ORDER BY service_id" | sed '$d' | sed -E 's/\s+([0-9]+)\s+\|\s+((\w|\s)+)/\1) \2/g'

  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED" | sed -E 's/^\s+|\s+$//g')

  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'" | sed -E 's/^\s+|\s+$//g')
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" > /dev/null
    fi

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ((SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'), $SERVICE_ID_SELECTED, '$SERVICE_TIME')" > /dev/null

    echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
