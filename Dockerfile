FROM ubuntu:20.04

RUN apt-get -y update && apt-get install -y jq lsb-release sudo wget

COPY virtual-environments/images/linux/ubuntu2004.json .
COPY virtual-environments/images/linux/scripts imagegeneration/
COPY virtual-environments/images/linux/toolsets/toolset-2004.json imagegeneration/installers/toolset.json

RUN chmod -R +x /imagegeneration

WORKDIR imagegeneration/installers

RUN ../base/repos.sh \
    && export IMAGE_VERSION="dev" && export IMAGE_OS="ubuntu20" \
    && export HELPER_SCRIPTS="/imagegeneration/helpers" && export INSTALLER_SCRIPT_FOLDER="/imagegeneration/installers" \
    && INSTALL_COMMANDS=$(jq --raw-output ' \
    .provisioners[] | select(.type == "shell") | select(.scripts).scripts[] | select(contains("installers")) | \
    ltrimstr("{{template_dir}}/scripts/installers/") | select(contains("preimagedata.sh") or contains("docker") | not)' \
    /ubuntu2004.json) \
    && for INSTALL_COMMAND in $INSTALL_COMMANDS; do \
        echo "Installing $INSTALL_COMMAND" \
        && case $INSTALL_COMMAND in \
            *.sh) \
                ./$INSTALL_COMMAND \
                ;; \
            *.ps1) \
                pwsh -f ./$INSTALL_COMMAND \
                ;; \
        esac \
    done
