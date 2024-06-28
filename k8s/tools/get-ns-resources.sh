resources(){ # 1=namespace 2=limits 3=cpu
    if [ $? -eq 0 ]
    then
    RESPONSE=$(kubectl -n ${1} get pods -o=jsonpath='{.items[*]..resources.'${2}'.'${3}'}')
    let TOTAL=0
        for i in $RESPONSE; do
            if [ $3 = "cpu" ]
            then
                if [[ $i =~ "m" ]]; then
                    i=$(echo $i | sed 's/[^0-9]*//g')
                    TOTAL=$(( TOTAL + i )) # milicores
                else
                    TOTAL=$(( TOTAL + i*1000 )) # cores to milicores
                fi
            elif [ $3 = "memory" ]
            then
                if [[ $i =~ "Mi" ]]; then
                    i=$(echo $i | sed 's/[^0-9]*//g')
                    TOTAL=$(( TOTAL + i )) # megabytes
                else
                    i=$(echo $i | sed 's/[^0-9]*//g')
                    TOTAL=$(( TOTAL + i*1000 )) # other (Gi, G) to megabytes
                fi
            fi
        done
        echo "> ${3} ${2}: $TOTAL"
    fi
}

NAMESPACES=("ert-dev" "news-dev")
for namespace in ${NAMESPACES[@]}; do
    echo "---> Namespace $namespace <---"
    resources $namespace "limits" "cpu"
    resources $namespace "requests" "cpu"
    resources $namespace "limits" "memory"
    resources $namespace "requests" "memory"
done
