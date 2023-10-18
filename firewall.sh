#!/bin/bash

# Colors
CYAN="\e[36m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
LRED="\e[91m"
RESET="\e[0m"

menu() {
  clear
  echo -e "\t\t\t\t\t${CYAN}UFW Firewall Administration Menu${RESET}\n"
  echo -e "1. ${GREEN}Add Rule or port${RESET}"
  echo -e "2. ${RED}Delete Rule${RESET}"
  echo -e "3. ${RED}Block IP Address${RESET}"
  echo -e "4. ${GREEN}Allow IP Address${RESET}"
  echo -e "5. ${CYAN}Firewall Status${RESET}"
  echo -e "6. ${YELLOW}Toggle Firewall (Enable/Disable)${RESET}"
  echo ""
  echo -e "7. ${LRED}Exit${RESET}"
  echo ""
  echo -n "Select an option: "
}

function ctrl_c {
    echo -e "\n\n${LRED}Bye!${RESET}"
    exit 1
}

trap ctrl_c INT

while true; do
  menu
  read option
  clear
  case $option in
    1)
      echo -n "Enter the rule to allow (example: 22/tcp): "
      read rule
      sudo ufw allow $rule
      ;;
    2)
      echo -n "Enter the rule to delete (example: 22/tcp): "
      read rule
      sudo ufw delete allow $rule
      ;;
    3)
      echo -n "Enter the IP address to block: "
      read ip
      sudo ufw deny from $ip
      ;;
    4)
      echo -n "Enter the IP address to allow: "
      read ip
      sudo ufw delete deny from $ip
      ;;
    5)
      sudo ufw status numbered | awk '/ALLOW/{gsub("ALLOW", "\033[1;32m&\033[0m"); print; next} /DENY/{gsub("DENY", "\033[1;31m&\033[0m"); print; next} /\(v6\)/{print "------------------"; print; next}1'    
      echo -e "\n${GREEN}Open ports:${RESET} $(sudo ufw status | awk '/ALLOW/ && !/v6/{sub("/tcp", "", $1); sub("/udp", "", $1); sub("/both", "", $1); print $1}' | tr '\n' ', ' | sed 's/,$//')"
      echo -e "${RED}Closed ports:${RESET} $(sudo ufw status | awk '/DENY/ && !/v6/{sub("/tcp", "", $1); sub("/udp", "", $1); sub("/both", "", $1); print $1}' | tr '\n' ', ' | sed 's/,$//')"

      ;;
    6)
      if sudo ufw status | grep -q "Status: active"; then
        echo -e "${YELLOW}Disabling the Firewall...${RESET}"
        sudo ufw disable
      else
        echo -e "${GREEN}Enabling the Firewall...${RESET}"
        sudo ufw enable
      fi
      ;;
    7)
      echo -e "${LRED}Exiting the script.${RESET}"
      exit 0
      ;;
    *)
      echo -e "${LRED}Invalid option. Please try again.${RESET}"
      ;;
  esac
  echo ""
  read -p "Press Enter to continue..."
done
