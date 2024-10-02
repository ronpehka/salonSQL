#!/bin/bash

# PSQL variable to connect to the database
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display the main menu and list services
MAIN_MENU() {
  echo -e "\nWelcome to My Salon, how can I help you?\n"

  # Fetch and display available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  
  # Display services in a formatted list
  echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done

  # Prompt user to select a service
  echo -e "\nPlease select a service by entering the corresponding number:"
  read SERVICE_ID_SELECTED

  # Check if the selected service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    # If the service doesn't exist, re-prompt the user
    MAIN_MENU "I could not find that service. Please select a valid service."
  else
    # Proceed with appointment booking
    BOOK_APPOINTMENT
  fi
}

# Function to book an appointment
BOOK_APPOINTMENT() {
  # Prompt for the customer's phone number
  echo -e "\nEnter your phone number:"
  read CUSTOMER_PHONE

  # Check if the customer exists in the database
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_ID ]]; then
    # If the customer doesn't exist, prompt for their name
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME

    # Insert new customer into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    # Get the new customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  else
    # Fetch the customer name if they exist
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id = $CUSTOMER_ID")
  fi

  # Prompt for the appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME appointment?"
  read SERVICE_TIME

  # Insert the appointment into the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Output the confirmation message
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Call the main menu function to start the script
MAIN_MENU

