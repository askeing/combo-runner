#!/bin/bash

GAIA_BRANCH=${GAIA_BRANCH:-"master"}
B2G_GAIATEST_LOCAL_PORT=${B2G_GAIATEST_LOCAL_PORT:-2828}
B2G_GAIATEST_TESTVARS=${B2G_GAIATEST_TESTVARS:-"testvars.json"}
B2G_GAIATEST_TYPE=${B2G_GAIATEST_TYPE:-"b2g"}
B2G_GAIATEST_TESTS=${B2G_GAIATEST_TESTS:-"gaiatest/tests/functional/manifest.ini"}
B2G_GAIATEST_TIMEOUT=${B2G_GAIATEST_TIMEOUT:-30000}

### Get the absolute path of testvars file
B2G_GAIATEST_TESTVARS_PATH=`readlink -f ${B2G_GAIATEST_TESTVARS}`
if [[ ! -f ${B2G_GAIATEST_TESTVARS_PATH} ]]; then
    echo "No testvars file [${B2G_GAIATEST_TESTVARS_PATH}] for gaia-ui-test."
    exit 1
else
    echo "The testvars file is [${B2G_GAIATEST_TESTVARS_PATH}]."
fi

### Checkout the Gaiatest project
if [[ -f common_check_gaia.sh ]]; then
    bash ./common_check_gaia.sh
else
    echo "There is no common_check_gaia.sh scripts."
    exit 1
fi

### change folder into gaia-ui-test
cd gaia/tests/python/gaia-ui-tests/

### remove old files
rm -rf results/

### Using virtual environments
rm -rf .env
virtualenv .env
source .env/bin/activate

### wait for device
adb wait-for-device
### do port forwarding
adb forward tcp:${B2G_GAIATEST_LOCAL_PORT} tcp:2828

### Setup gaiatest
rm -rf gaiatest/atoms
python setup.py develop
pip install -Ur gaiatest/tests/requirements.txt

### Run gaiatest
echo "Running gaiatest on desktop B2G, type [${B2G_GAIATEST_TYPE}], tests [${B2G_GAIATEST_TESTS}]..."
gaiatest --address=localhost:${B2G_GAIATEST_LOCAL_PORT} --testvars=${B2G_GAIATEST_TESTVARS_PATH} --xml-output=results/result.xml --html-output=results/index.html --restart --timeout=${B2G_GAIATEST_TIMEOUT} --type=${B2G_GAIATEST_TYPE} ${B2G_GAIATEST_TESTS}

### reboot
adb reboot

