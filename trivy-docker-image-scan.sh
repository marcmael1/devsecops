#!/bin/bash

dockerImageName=$(awk 'NR==1 {print $2}' Dockerfile) #Getting based-image from Dockerfile using awk
echo $dockerImageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 0 --severity HIGH --light $dockerImageName  #This docker command find any high severity and ignore them
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 -q image --exit-code 1 --severity CRITICAL --light $dockerImageName #This docker command find any critical severity and fail the build 

    # Trivy scan result processing
    exit_code=$?
    echo "Exit Code : $exit_code" #here we output exit code

    # Check scan results
    if [[ "${exit_code}" == 1 ]]; then      # here we fail the build if exit-code=1 (which mean it found Critical vulnerability) and pass if 0
        echo "Image scanning failed. Vulnerabilities found"
        exit 1;
    else
        echo "Image scanning passed. No CRITICAL vulnerabilities found"
    fi;