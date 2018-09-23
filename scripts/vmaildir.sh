#!/bin/bash

op="$1"
maildir_base=/home/vmail/u

case ${op} in

    create)
        u=`echo "$2" | tr -dc '[:alnum:]_.'`
        if [ -e ${maildir_base}/${u} ]
        then
            echo "Target already exists: ${maildir_base}/${u}"
            exit 1
        fi
        mkdir ${maildir_base}/${u} && chmod ug=rwx,o= ${maildir_base}/${u}
        ;;

    rename)
        u=`echo "$2" | tr -dc '[:alnum:]_.'`
        n=`echo "$3" | tr -dc '[:alnum:]_.'`
        if [ ! -e ${maildir_base}/${u} ]
        then
            echo "Source does not exist: ${maildir_base}/${u}"
            exit 1
        fi
        if [ -e ${maildir_base}/${n} ]
        then
            echo "Target already exists: ${maildir_base}/${n}"
            exit 1
        fi
        mv ${maildir_base}/${u} ${maildir_base}/${n}
        ;;

    delete)
        u=`echo "$2" | tr -dc '[:alnum:]_.'`
        if [ ! -e ${maildir_base}/${u} ]
        then
            echo "Target does not exist: ${maildir_base}/${u}"
            exit 1
        fi
        rm -rf ${maildir_base}/${u}
        ;;

    *)
        echo "Unrecognized command: ${op}"
        exit 127
        ;;
esac
