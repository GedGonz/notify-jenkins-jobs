#!/bin/bash

# Variables
JENKINS_URL=${JENKINS_URL}  # Variable de entorno de la url de jenkins
USER=${JENKINS_USER}	    # Variable de entorno del usuario de jenkins
API_TOKEN=${JENKINS_TOKEN}  # Variable de entorno del toke de jenkins

expire_time=1000

# Obtener la fecha actual en formato YYYY-MM-DD
today=$(date +"%Y-%m-%d")

# Ruta del archivo de registro de la última notificación
notification_file="/tmp/jenkins_notifications"
mkdir -p "$notification_file" 2>/dev/null


# Verificar si las variables de entorno están configuradas
if [[ -z "$JENKINS_URL" ]] || [[ -z "$JENKINS_USER" ]] || [[ -z "$JENKINS_TOKEN" ]]; then
  echo "Error: JENKINS_URL, JENKINS_USER Y JENKINS_TOKEN deben estar configuradas."
  exit 1
fi



# Obtener la lista de trabajos
jobs=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$JENKINS_URL/api/json" | jq -r '.jobs[] | .name')

# Iterar sobre cada trabajo
for job in $jobs; do
    echo "Checking job: $job"

    # Obtener la última construcción del trabajo
    last_build=$(curl -s -u "$JENKINS_USER:$JENKINS_TOKEN" "$JENKINS_URL/job/$job/lastBuild/api/json")

    # Comprobar si se obtuvo la última construcción
    if [[ -z "$last_build" ]]; then
        echo "No builds found for job: $job"
        continue
    fi

    number=$(echo "$last_build" | jq -r '.number')
    result=$(echo "$last_build" | jq -r '.result')
    timestamp=$(echo "$last_build" | jq -r '.timestamp | todateiso8601')
    url="$(echo "$last_build" | jq -r '.url')console"

    # Convertir el timestamp a la fecha en formato YYYY-MM-DD
    build_date=$(date -d @"$(echo "$last_build" | jq -r '.timestamp / 1000')" +"%Y-%m-%d")

    # Comprobar si la construcción es de hoy
    if [[ "$build_date" == "$today" ]]; then
        # Solo imprimir si el resultado es uno de los estados deseados
        if [[ "$result" == "SUCCESS" ]]; then
            echo "Job: $job - Build Number: $number - Result: $result - Timestamp: $timestamp"
	    notif_file="$notification_file/$job.notif" 
            # Leer la fecha de la última notificación
            last_notification_date=$(cat "$notif_file" 2>/dev/null)

            # Comprobar si se debe enviar una notificación
            if [[ "$last_notification_date" != "$today" ]]; then
                # Enviar la notificación en segundo plano
                notify-send -a "Resultado de ejecución" "Job: $job - Result: $result" -i /usr/local/bin/jenkins.ico --expire-time=$expire_time &
                
                # Actualizar el archivo con la fecha de hoy
                echo "$today" > "$notif_file"
            fi
        fi
        if [[ "$result" == "FAILURE" || "$result" == "UNSTABLE" ]]; then
            echo "Job: $job - Build Number: $number - Result: $result - Timestamp: $timestamp"
	    notif_file="$notification_file/$job.notif" 
            # Leer la fecha de la última notificación
            last_notification_date=$(cat "$notif_file" 2>/dev/null)

            # Comprobar si se debe enviar una notificación
            if [[ "$last_notification_date" != "$today" ]]; then
                # Enviar la notificación en segundo plano
                notify-send -a "Resultado de ejecución" "Job: $job - Result: $result" $url -i /usr/local/bin/jenkins.ico --expire-time=$expire_time &
                
                # Actualizar el archivo con la fecha de hoy
                echo "$today" > "$notif_file"
            fi
        fi


    fi
done

