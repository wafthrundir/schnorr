#!/bin/bash

red() {
    echo -e "\033[38;5;196m** $1\033[m"
}

green() {
    echo -e "\033[32m** $1\033[m"
}

blue() {
    echo -e "\033[34m** $1\033[m"
}

yellow() {
    echo -e "\033[38;5;220m** $1\033[m"
}

any_key() {
  green "Press any key to continue or wait 10 seconds..."
  read -s -n 1 -t 10
}