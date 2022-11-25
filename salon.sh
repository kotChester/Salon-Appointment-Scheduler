#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
    SERVICES=$($PSQL "select service_id, name from services")
    
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do
        echo "$SERVICE_ID) $NAME"
    done
    
    read SERVICE_ID_SELECTED
    
    SERVICE_ID_SELECTED_RETURN=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_ID_SELECTED_RETURN ]]
    then
        echo -e "\nI could not find that service. What would you like today?"
        MAIN_MENU
    else
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        
        CUSTOMER_ID_RETURN=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_ID_RETURN ]]
        then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            
            ADD_CUSTOMER=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
            CUSTOMER_ID_RETURN=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
        fi
        
        CUSTOMER_NAME=$($PSQL "select name from customers where customer_id='$CUSTOMER_ID_RETURN'")
        
        CUSTOMER_NAME_F=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
        SERVICE_NAME_F=$(echo $SERVICE_ID_SELECTED_RETURN | sed 's/ |/"/')
        
        echo -e "\nWhat time would you like your $SERVICE_NAME_F, $CUSTOMER_NAME_F?"
        read SERVICE_TIME
        
        APP_ADD=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID_RETURN, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
        
        echo "I have put you down for a $SERVICE_NAME_F at $SERVICE_TIME, $CUSTOMER_NAME_F."
    fi
}

MAIN_MENU
