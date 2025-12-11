#!/bin/bash
inputNewIp=""
currentIp=`hostname -I`
validate="true"

echo "Votre IP est : $(hostname -I)"
read -p "Entrez la nouvelle IP : " inputNewIp

# Validate IP format and range
if [[ $inputNewIp =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    for i in {1..4}; do
        echo "Checking octet $i"
        octet=$(echo $inputNewIp | cut -d. -f$i)
        n=`expr "$octet" : '.*'`
        # Validate IPv4 format
        if ((n>3)); then
            validate="false"
            echo "$inputNewIp n'est pas une adresse IPv4 valide."
        fi
        # Validate octet range
        if (( octet < 0 || octet > 255 )); then
            validate="false"
        else
            # Validate private IP ranges
            if [[ $inputNewIp =~ ^(10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(1[6-9]|2[0-9]|3[0-1])\.[0-9]{1,3}\.[0-9]{1,3})$ ]]; then
                validate="true"
            else
                echo "$inputNewIp n'est pas une adresse IPv4 privée."
                validate="false"
            fi
        fi
    done
fi


#Get Default Network Interface
default_interface=$(ip route | grep default | awk '{print $5}')
if [ -z "$default_interface" ]; then
    echo "Impossible de déterminer l'interface réseau par défaut."
    exit 1
fi

echo "Interface par défaut : $default_interface"

#Check if IP is already assigned to the interface
if ip addr show dev $default_interface | grep -q "$inputNewIp"; then
    echo "L'adresse IP $inputNewIp est déjà assignée à l'interface $default_interface."
    validate="false"
fi

#Check if IP is already in use
ping -c 1 -W 1 $(echo $inputNewIp | cut -d/ -f1) > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "L'adresse IP $inputNewIp est déjà utilisée par un autre appareil sur le réseau."
    validate="false"
fi

if [ "$validate" = true ] ; then
    echo "L'adresse IP $inputNewIp est valide et privée."
    echo "Ajout de l'adresse IP $inputNewIp/24 à l'interface $default_interface en cours..."

    #Delete Current IP
    sudo ip addr del $currentIp dev $default_interface
    if [ $? -ne 0 ]; then
        echo "Échec de la suppression de l'adresse IP $currentIp/24 de l'interface $default_interface."
        exit 1
    fi
    sleep 3
    echo "$currentIp/24 à été supprimé"
    sleep 3

    #Add New IP
    sudo ip addr add $inputNewIp/24 dev $default_interface 
    if [ $? -ne 0 ]; then
        echo "Échec de l'ajout de l'adresse IP $inputNewIp/24 à l'interface $default_interface."
        exit 1
    fi

    if [ $? -eq 0 ]; then
        echo "Adresse IP $inputNewIp/24 ajoutée avec succès à l'interface $default_interface."
    else
        echo "Échec de l'ajout de l'adresse IP $inputNewIp/24 à l'interface $default_interface."
    fi
fi
