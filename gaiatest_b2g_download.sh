#!/bin/bash

if [[ -z ${DOWNLOAD_BASE_URL} ]]; then
    echo "### No DOWNLOAD_BASE_URL value."
    echo "### Setting the DOWNLOAD_BASE_URL to latest Mozilla Central Flame engineer build..."
fi
DOWNLOAD_BASE_URL=${DOWNLOAD_BASE_URL:-"http://ftp.mozilla.org/pub/mozilla.org/b2g/nightly/latest-mozilla-central-flame-eng/"}

function prepare_env() {
    echo "### Preparing Environment..."
    if ! which wget > /dev/null; then
        read -p "Package \"wget\" not found! Install? [Y/n]" REPLY
        test "$REPLY" == "n" || test "$REPLY" == "N" && echo "byebye." && exit 0
        sudo apt-get install wget
    fi
    ### Create temp folder
    if ! which mktemp > /dev/null; then
        echo "### Package \"mktemp\" not found!"
        rm -rf ./b2g_download_temp
        mkdir b2g_download_temp
        cd b2g_download_temp
        DL_DIR=`pwd`
        cd ..
    else
        rm -rf /tmp/b2g_download_temp*
        DL_DIR=`mktemp -d -t b2g_download_temp.XXXXXXXXXXXX`
    fi
    echo "Download Folder: ${DL_DIR}"
}

function find_gecko_name_for_download() {
    LOCAL_PAGE_NAME="page"
    DOWNLOAD_OBJ="${DOWNLOAD_BASE_URL}?C=M;O=D"
    wget -qO ${DL_DIR}/${LOCAL_PAGE_NAME} ${DOWNLOAD_OBJ}
    GECKO_NAME=`cat ${DL_DIR}/${LOCAL_PAGE_NAME} | grep b2g-.*\.android-arm\.tar\.gz | sed 's/.*b2g-/b2g-/' | sed 's/gz.*/gz/' | head -1`
}

function download_gecko() {
    LOCAL_GECKO_NAME="b2g.tar.gz"
    DOWNLOAD_OBJ="${DOWNLOAD_BASE_URL}${GECKO_NAME}"
    DOWNLOAD_TARGET="${DL_DIR}/${LOCAL_GECKO_NAME}"
    echo "### Downloading: ${DOWNLOAD_OBJ}"
    wget -qO ${DOWNLOAD_TARGET} ${DOWNLOAD_OBJ}
    if [[ $? != 0 ]]; then
        echo "### Can not download ${DOWNLOAD_OBJ}"
        exit 1
    fi
    echo "### Download To: ${DOWNLOAD_TARGET}"
    LOCAL_GECKO_FILE=${DOWNLOAD_TARGET}
}

function download_gaia() {
    GAIA_NAME="gaia.zip"
    LOCAL_GAIA_NAME="gaia.zip"
    DOWNLOAD_OBJ="${DOWNLOAD_BASE_URL}${GAIA_NAME}"
    DOWNLOAD_TARGET="${DL_DIR}/${LOCAL_GAIA_NAME}"
    echo "### Downloading: ${DOWNLOAD_OBJ}"
    wget -qO ${DOWNLOAD_TARGET} ${DOWNLOAD_OBJ}
    if [[ $? != 0 ]]; then
        echo "### Can not download ${DOWNLOAD_OBJ}"
        exit 1
    fi
    echo "### Download To: ${DOWNLOAD_TARGET}"
    LOCAL_GAIA_FILE=${DOWNLOAD_TARGET}
}

function download_sources_xml() {
    SOURCES_NAME="sources.xml"
    LOCAL_SOURCES_NAME="sources.xml"
    DOWNLOAD_OBJ="${DOWNLOAD_BASE_URL}${SOURCES_NAME}"
    DOWNLOAD_TARGET="${DL_DIR}/${LOCAL_SOURCES_NAME}"
    echo "### Downloading: ${DOWNLOAD_OBJ}"
    wget -qO ${DOWNLOAD_TARGET} ${DOWNLOAD_OBJ}
    if [[ $? != 0 ]]; then
        echo "### Can not download ${DOWNLOAD_OBJ}"
        exit 1
    fi
    echo "### Download To: ${DOWNLOAD_TARGET}"
    LOCAL_SOURCES_FILE=${DOWNLOAD_TARGET}
}

prepare_env
find_gecko_name_for_download
download_gaia
download_gecko
download_sources_xml

export LOCAL_GAIA_FILE
export LOCAL_GECKO_FILE
export LOCAL_SOURCES_FILE
echo "### Gaia package: [${LOCAL_GAIA_FILE}]"
echo "### Gecko package: [${LOCAL_GECKO_FILE}]"
echo "### Sources file: [${LOCAL_SOURCES_FILE}]"

