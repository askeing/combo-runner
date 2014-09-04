#!/bin/bash

### for other bash script tools call.
case `uname` in
    "Linux"|"CYGWIN"*) SP="=";;
    "Darwin") SP=" ";;
esac

if [[ -z ${LOCAL_GAIA_FILE} ]]; then
    echo "### No LOCAL_GAIA_FILE value."
    echo "### Setting the value to [gaia.zip]"
fi
LOCAL_GAIA_FILE=${LOCAL_GAIA_FILE:-"gaia.zip"}
LOCAL_GAIA_FILE=`readlink -f ${LOCAL_GAIA_FILE}`
echo "${LOCAL_GAIA_FILE}"
if [[ ! -f "${LOCAL_GAIA_FILE}" ]]; then
    echo "### No [${LOCAL_GAIA_FILE}] file"
    exit 1
fi

if [[ -z ${LOCAL_GECKO_FILE} ]]; then
    echo "### No LOCAL_GECKO_FILE value."
    echo "### Setting the value to [b2g.tar.gz]"
fi
LOCAL_GECKO_FILE=${LOCAL_GECKO_FILE:-"b2g.tar.gz"}
LOCAL_GECKO_FILE=`readlink -f ${LOCAL_GECKO_FILE}`
if [[ ! -f "${LOCAL_GECKO_FILE}" ]]; then
    echo "### No [${LOCAL_GECKO_FILE}] file"
    exit 1
fi

echo "### Flashing Phone with Gaia [${LOCAL_GAIA_FILE}], Gecko [${LOCAL_GECKO_FILE}]..."

### Checkout the B2G-flash-tool project
if [[ -f common_check_B2G-flash-tool.sh ]]; then
    bash ./common_check_B2G-flash-tool.sh
else
    echo "There is no common_check_B2G-flash-tool.sh scripts."
    exit 1
fi

### Download B2G desktop client
CUR_DIR=`pwd`
cd ./B2G-flash-tool
./shallow_flash.sh --gaia${SP}${LOCAL_GAIA_FILE} --gecko${SP}${LOCAL_GECKO_FILE} -y
./check_versions.sh | grep 'Gaia\|Gecko\|BuildID\|Version' | sed 's/\s\+/="/g' | sed 's/$/"/g' > VERSION
source VERSION
rm VERSION
cd ${CUR_DIR}

export DEVICE_B2G_BUILD_ID=${BuildID}
export DEVICE_B2G_GAIA=${Gaia}
export DEVICE_B2G_GECKO=${Gecko}
export DEVICE_B2G_VERSION=${Version}
echo "### Build ID is [${DEVICE_B2G_BUILD_ID}]"
echo "### Gaia Rev is [${DEVICE_B2G_GAIA}]"
echo "### Gecko Rev is [${DEVICE_B2G_GECKO}]"

