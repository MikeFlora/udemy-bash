#!/bin/bash

function isNumber() {
  isNum="false"
  if [[ $char =~ ^[0-9]+$ ]]
  then
    isNum="true"
  fi
}

function getLocation() {
  LOCATION=""
  local FOUND_NUM="false"
  
  for (( i=0; i<${#str}; i++ ))
  do
    local char=${str:$i:1}
    isNumber ${char}
    
    if [[ "${isNum}" == "true" ]]
    then
      LOCATION=${LOCATION}${char}
      FOUND_NUM="true"
    else
      if [[ "${FOUND_NUM}" == "true" ]]
      then
        break
      else
        LOCATION=${LOCATION}${char}
      fi
    fi
#    echo "${char} is a number? ${isNum}"
  done
}

#str="usoh4plssd01.domain.tld"
str=$1

#getLocation $1
LOCATION=${str:0:5}
ENVIRONMENT=${str:5:1}
OS=${str:6:1}
TYPE=${str:7:3}
COUNT=${str:10:2}
DOMAIN=${str:13}

echo "Location:    ${LOCATION}"
echo "Environment: ${ENVIRONMENT}"
echo "OS:          ${OS}"
echo "Type:        ${TYPE}"
echo "Count:       ${COUNT}"
echo "Domain:      ${DOMAIN}"
