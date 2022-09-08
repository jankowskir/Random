#!/bin/bash

#To use this script, run ./checkA.sh {hostname} {query type a|ptr|soa}

host=$1

#Get all of the DNS servers in AD into $array[]
mapfile -t array < <(nslookup -type=NS hcbocc.ad | grep hcbocc.ad | cut -f 2 -d "=" | cut -f 2 -d " " | sort)

#Add the Umbrella servers
array+=(
    "ctyctr-umbva1.hcbocc.ad"
    "ctyctr-umbva2.hcbocc.ad"
    "psoc-umbva1.hcbocc.ad"
    "psoc-umbva2.hcbocc.ad"
    "sp-umbva1.hcbocc.ad"
    "sp-umbva2.hcbocc.ad"
    )

#Run the test and display the output
for i in ${!array[@]}; do
    if [ -z ${2} ]; then
        echo "Missing command variable"
        echo "Usage ./checkDNS.sh {query} {query type a|ptr|soa}"
        exit
    elif [ $2 == "a" ]; then 
        output=$(dig +short $host @${array[$i]})
    elif [ $2 == "soa" ]; then
        output=$(dig -t soa +short $host @${array[$i]})
    elif [ $2 == "ptr" ]; then
        output=$(dig -x $host @${array[$i]} | grep PTR | grep -v ";")
    else
        echo "Unknown command variable $2"
        echo "Usage ./checkDNS.sh {query} {query type a|ptr|soa}"
        exit
    fi
    if [ $(echo $output | wc -c) -le 2 ]; then
        output="No result"
    fi

    len=$(echo ${array[$i]} | wc -c)
    if [ $len -le 18 ]; then 
        echo -e ${array[$i]} says:'\t \t \t' $output
    elif [ $len -ge 18 ]; then 
        echo -e ${array[$i]} says:'\t \t' $output
    fi
done
