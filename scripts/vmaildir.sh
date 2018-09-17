#!/bin/bash

op="$1"

case ${op} in

    create)
        u=`echo "$2" | tr -dc '[:alnum:]_.'`
        if [ -e /home/vmail/${u} ]
        then
            echo "Target already exists: /home/vmail/${u}"
            exit 1
        fi
        mkdir /home/vmail/${u} && chmod u=rwx,go= /home/vmail/${u}
        ;;

    rename)
        u=`echo "$2" | tr -dc '[:alnum:]_.'`
        n=`echo "$3" | tr -dc '[:alnum:]_.'`
        if [ ! -e /home/vmail/${u} ]
        then
            echo "Source does not exist: /home/vmail/${u}"
            exit 1
        fi
        if [ -e /home/vmail/${n} ]
        then
            echo "Target already exists: /home/vmail/${n}"
            exit 1
        fi
        mv /home/vmail/${u} /home/vmail/${n}
        ;;

    delete)
        u=`echo "$2" | tr -dc '[:alnum:]_.'`
        if [ ! -e /home/vmail/${u} ]
        then
            echo "Target does not exist: /home/vmail/${u}"
            exit 1
        fi
        rm -rf /home/vmail/${u}
        ;;
esac
