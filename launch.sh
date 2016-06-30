#!/bin/bash

# Initialize the App
# eb init <-- pas through typrical information, DNS name, region etc

# Create the environment
eb create --database # add more options to tailor the environment

# set environment variables needed for the Deploy
eb setenv # script that parses the overrides into K=V style
