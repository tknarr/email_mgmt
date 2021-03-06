#!/bin/bash

[ -e /etc/profile ] && . /etc/profile
[ -e /etc/bash.basnrc ] && . /etc/bash.bashrc
[ -e ${HOME}/.profile ] && . ${HOME}/.profile

PCTL="bin/bundle exec pumactl -S ${HOME}/app/shared/tmp/pids/puma.state"

cd ${HOME}/app/current
case $1 in
    start)
        bin/bundle exec puma -C ${HOME}/app/shared/puma.rb --daemon
        ;;

    stop)
        $PCTL stop
        ;;

    restart)
        $PCTL restart
        ;;
esac
