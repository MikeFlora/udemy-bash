#!/bin/bash

############################################
# Naming Convention definitions
# <location><environment><os><type><count>.domain.tld
############################################
HOST_LOCATION_START=0
HOST_LOCATION_LEN=5

HOST_ENVIRONMENT_START=5
HOST_ENVIRONMENT_LEN=1

HOST_OS_START=6
HOST_OS_LEN=1

HOST_TYPE_START=7
HOST_TYPE_LEN=3

HOST_COUNT_START=10
HOST_COUNT_LEN=2

HOST_DOMAIN_START=13
############################################

############################################
# Determine the name of the Environment
# Parameter: hostname/fqdn
function getEnvironment() {
  case ${1,,} in
    p)
      ENVIRONMENT="Production"
      ;;

    d)
      ENVIRONMENT="Development"
      ;;

    *)
      ENVIRONMENT="Other"
      ;;
  esac
}

##############################################
# Determine the name of the OS
# Parameter: OS character code
##############################################
function getOS() {
  case ${1,,} in
    l)
      OS="Linux"
      ;;

    w)
      OS="Windows"
      ;;

    *)
      OS="Other"
      ;;
  esac
}

##############################################
# Parse the naming conention elements of the hostname
##############################################
function parseName() {
  local str=$1
  
  LOCATION=${str:$HOST_LOCATION_START:$HOST_LOCATION_LEN}
  getEnvironment ${str:$HOST_ENVIRONMENT_START:$HOST_ENVIRONMENT_LEN}
  getOS ${str:$HOST_OS_START:$HOST_OS_LEN}
  TYPE=${str:$HOST_TYPE_START:$HOST_TYPE_LEN}
  COUNT=${str:$HOST_COUNT_START:$HOST_COUNT_LEN}
  DOMAIN=${str:$HOST_DOMAIN_START}
}

##############################################
# Print the naming convention parts of the current hostname
##############################################
function printInfo() {
  echo "Location:    ${LOCATION}"
  echo "Environment: ${ENVIRONMENT}"
  echo "OS:          ${OS}"
  echo "Type:        ${TYPE}"
  echo "Count:       ${COUNT}"
  echo "Domain:      ${DOMAIN}"
}

##############################################
# Read the files that are provided as command-line
# parameters and process the hostnames (one per line)
##############################################
function readFiles() {
  # File names sent as parameters
  # Iterate through each filename passed
  for FILE in $@;
  do
    # Initialize an array to hold the stats for the current file
    declare -A ARR_STATS
    ARR_STATS=([OS_Linux]=0 [OS_Windows]=0 [OS_Other]=0 [ENV_Production]=0 [ENV_Development]=0 [ENV_Other]=0)
    
    # Array to hold the hostnames that are deemed invalid
    INVALID=()

    # Initialize variables for parsing each file
    LOCATION=""
    ENVIRONMENT=""
    OS=""
    TYPE=""
    COUNT=""
    DOMAIN=""

    # Read the contents of the file
    while read LINE
    do
      # Get the hostname only from the line in the file
      local baseName
      IFS="." read -ra baseName <<< $LINE
      
      # Check to see if the hostname is the correct length according to the naming convention
      if [ ${#baseName} -lt 12 ]
      then
        # If not, then add the line contents to the "INVALID" array
        INVALID+=("${LINE}")
        
        # Continue to the next line in the file
        continue
      fi
      
      # Get the naming convention elements from the hostname
      parseName $LINE
      
      # Increment OS Stats based on the current hostname
      case $OS in
        Linux)
          (( ARR_STATS[OS_Linux]++ ))
          ;;
        Windows)
          (( ARR_STATS[OS_Windows]++ ))
          ;;
        *)
          (( ARR_STATS[OS_Other]++ ))
          ;;
      esac
      
      # Increment the ENVIRONMENT Stats based on the current hostname
      case $ENVIRONMENT in
        Production)
          (( ARR_STATS[ENV_Production]++ ))
          ;;
        Development)
          (( ARR_STATS[ENV_Development]++ ))
          ;;
        *)
          (( ARR_STATS[ENV_Other]++ ))
          ;;
      esac
      
    done < ${FILE}
    
    # Print stats for each file
    echo "=============================="
    echo "File = ${FILE}"
    echo "=============================="
    echo "OS Windows              = ${ARR_STATS[OS_Windows]}"
    echo "OS Linux                = ${ARR_STATS[OS_Linux]}"
    echo "OS Other                = ${ARR_STATS[OS_Other]}"
    echo "Environment Production  = ${ARR_STATS[ENV_Production]}"
    echo "Environment Development = ${ARR_STATS[ENV_Development]}"
    echo "Environment Other       = ${ARR_STATS[ENV_Other]}"
    echo
    echo "The following hostnames do not conform to the naming convention:"
    
    for i in "${INVALID[@]}"
    do
      echo "$i"
    done
    echo
  done
}

clear
readFiles $@

