# notify-jenkins-jobs

Este es un pequeño script para mostar notificaciones por cada ultima ejecución en cada job por dia en el sistema operativo en este caso para linux

## Configuración: 

Para configurar este script es necesario crear un cron para ejecutar este en un tiempo determinado y agregar las variables de tornos necesarias

### Variable de entorno: 

- JENKINS_URL="https://urljenkisn.com"
- JENKINS_USER="user jenkins"
- JENKINS_TOKEN="token de jenkins"

### Cron: 
crear una carpeta para almacenar el log del script(opcional)

*/5 8-17 * * *  XDG_RUNTIME_DIR=/run/user/$(id -u) /usr/local/bin/jenkinsMonitor.sh >> /usr/local/bin/logs/jenkins.log 2>&1
