#!/bin/ash
PROJECT=paper
USER_AGENT="Pterodactyl (https://Pterodactyl.io)"

cd /home/container

echo -e "Checking latest build for Paper ${MINECRAFT_VERSION}..."

if ! which jq >/dev/null 2>&1; then
    apk add --no-cache jq 2>/dev/null
fi

LATEST_BUILD=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION} | jq -r '.builds' | jq -r '.[0]'`

if [ -z "${LATEST_BUILD}" ] || [ "${LATEST_BUILD}" == "null" ]; then
    echo -e "Impossible de récupérer le dernier build. Le serveur va démarrer avec le jar actuel."
    exit 0
fi

DOWNLOAD_URL=`curl --user-agent "${USER_AGENT}" -s https://fill.papermc.io/v3/projects/${PROJECT}/versions/${MINECRAFT_VERSION}/builds/${LATEST_BUILD} | jq -r '.downloads."server:default".url'`

echo -e "Dernier build disponible : ${LATEST_BUILD}"

if [ -f ${SERVER_JARFILE} ]; then
    mv ${SERVER_JARFILE} ${SERVER_JARFILE}.old
fi

echo -e "Téléchargement du build ${LATEST_BUILD}..."
curl --user-agent "${USER_AGENT}" -o ${SERVER_JARFILE} ${DOWNLOAD_URL}

echo -e "Mise à jour terminée."
