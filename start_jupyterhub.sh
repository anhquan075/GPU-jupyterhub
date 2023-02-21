#!/bin/bash

generate_self_certificate() {
    echo "Generating self certificate..."
    DAYS="365"
    PASSPHRASE=""
    COUNTRY=""
    STATE=""
    CITY=""
    ORGANIZATION=""
    ORG_UNIT=""
    EMAIL=""

    openssl req -newkey rsa:2048 -nodes -keyout secrets/privkey.pem -x509 -days ${DAYS} -out secrets/cert.pem \
        -subj "/C=${COUNTRY}/ST=${STATE}/L=${CITY}/O=${ORGANIZATION}/OU=${ORG_UNIT}/CN=${CERT_NAME}/emailAddress=${EMAIL}"
}

add_environment_variables() {
    echo "Adding environment variables..."

    # Function to update an environment variable in the environment file
    function update_environment_variable() {
        local var_name="$1"
        local var_value="$2"

        # Read the environment file into an array of lines
        IFS=$'\n' read -d '' -r -a lines < .env

        # Update the value for the variable in the environment file
        for i in "${!lines[@]}"
        do
            if [[ "${lines[$i]}" == "${var_name}="* ]]; then
                lines[$i]="${var_name}=${var_value}"
            fi
        done

        # If the variable is not already present in the file, add it as a new line
        if ! [[ " ${lines[@]} " =~ " ${var_name}=" ]]; then
            lines+=("${var_name}=${var_value}")
        fi

        # Write the modified lines back to the environment file
        printf '%s\n' "${lines[@]}" > .env
    }

    # Read NGROK_AUTHTOKEN from keyboard
    while [ -z "$NGROK_AUTHTOKEN" ]
    do
        read -p "Please enter the value for NGROK_AUTHTOKEN: " NGROK_AUTHTOKEN
    done

    # Update the value for NGROK_AUTHTOKEN in the environment file
    update_environment_variable "NGROK_AUTHTOKEN" "$NGROK_AUTHTOKEN"

    # Read HOST_PERSONAL_NETWORK_FOLDER from keyboard
    while [ -z "$HOST_PERSONAL_NETWORK_FOLDER" ]
    do
        read -p "Please enter the value for HOST_PERSONAL_NETWORK_FOLDER: " HOST_PERSONAL_NETWORK_FOLDER
    done

    # Update the value for HOST_PERSONAL_NETWORK_FOLDER in the environment file
    update_environment_variable "HOST_PERSONAL_NETWORK_FOLDER" "$HOST_PERSONAL_NETWORK_FOLDER"

    # Read HOST_SHARED_NETWORK_FOLDER from keyboard
    while [ -z "$HOST_SHARED_NETWORK_FOLDER" ]
    do
        read -p "Please enter the value for HOST_SHARED_NETWORK_FOLDER: " HOST_SHARED_NETWORK_FOLDER
    done

    # Update the value for HOST_SHARED_NETWORK_FOLDER in the environment file
    update_environment_variable "HOST_SHARED_NETWORK_FOLDER" "$HOST_SHARED_NETWORK_FOLDER"
}

create_postgres_env() {
    # Define the variables
    POSTGRES_DB="$1"
    POSTGRES_PASSWORD="$2"

    # Write the variables to postgre.env
    touch ./secrets/postgres.env
    echo "POSTGRES_DB=${POSTGRES_DB}" >> ./secrets/postgres.env
    echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >> ./secrets/postgres.env
}

create_user_list() {
    # Modify the variables to create the user list
    touch userlist
    echo "admin admin" > userlist
    echo "quannla quannla" >> userlist
    # Add many users as you want
}

main() {
    # Create the environment file
    mv .env.example .env
    # Create the secret folder
    mkdir -p ./secrets

    # Generate the self-signed certificate
    generate_self_certificate 
    # Add your enviroment variables
    add_environment_variables
    # Modify your postgre database
    create_postgres_env "database" "123456"
    # Create the user list
    create_user_list 

    # Run the system
    docker compose up --build
}

main "$1"