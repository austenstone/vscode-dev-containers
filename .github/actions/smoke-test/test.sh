#/bin/bash
DEFINITION="$1"
IMAGE="$2"
USERNAME="$3"

# Run test script for image if one exists

export DOCKER_BUILDKIT=1

if [ "${IMAGE}" = "none" ]; then
    echo "Image not specified. Aborting test."
    exit 0
fi

set -e

# Start container
echo "(*) Starting container..."
container_name="$DEFINITION"
docker run -d --name ${container_name} --rm --init --privileged -v "$(pwd)/containers/${DEFINITION}:/workspace" ${IMAGE} /bin/sh -c 'while sleep 1000; do :; done'

# Fake out existence of extensions, VS Code Server
echo "(*) Stubbing out extensions and VS Code Server..."
dev_container_relative_path="containers/${DEFINITION}/.devcontainer"
mkdir -p "/tmp/${dev_container_relative_path}"
cp -f "$(pwd)/${dev_container_relative_path}/devcontainer.json" "/tmp/${dev_container_relative_path}/"
dev_container_tmp="/tmp/${dev_container_relative_path}/devcontainer.json"
sed -i'.bak' -e "s/\\/\\/.*/ /g" "${dev_container_tmp}"
extensions="$(jq '.extensions' --compact-output "${dev_container_tmp}" | tr -d '[' | tr -d ']' | tr ',' '\n' 2>/dev/null || echo -n '')"
docker exec -u "${USERNAME}" ${container_name} /bin/sh -c "\
    mkdir -p \$HOME/.vscode-server/bin \$HOME/.vscode-server/extensions \
    && cd \$HOME/.vscode-server/extensions \
    && if [ \"${extensions}\" != '' ]; then echo \"${extensions}\" | xargs -n 1 mkdir -p; fi \
    && find \$HOME/.vscode-server/ -type d"

# Run actual test
echo "(*) Running test..."
docker exec -u "${USERNAME}" ${container_name} /bin/sh -c  '\
    set -e \
    && cd /workspace \
    && if [ -f "test-project/test.sh" ]; then \
    cd test-project \
    && if [ "$(id -u)" = "0" ]; then \
        chmod +x test.sh; \
    else \
        sudo chmod +x test.sh; \
    fi \
    && ./test.sh; \
    else \
    ls -a; 
    fi'

# Clean up
docker rm -f ${container_name}