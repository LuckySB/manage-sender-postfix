#!/bin/sh

# list of relay servers
SENDERS="12 15 16 19 20 21 22 23 24 25 26 27 28 29 30 31"
QUEUE="all active bounce deferred hold incoming"

function show_help {
 echo "Usage $0 -s|--slave all|list of server -c|--command command_string"
 echo "  command_string: "
 echo "       start | stop | restart | status"
 echo "       remove_all all|queue name(active|deferred|bounce|hold|incoming)"
 echo "       remove_to all|queue name(active|deferred|bounce|hold|incoming) recipient domen"
 echo "       remove_from all|queue name(active|deferred|bounce|hold|incoming) sender domen"
 echo "       remove_camp all|queue name(active|deferred|bounce|hold|incoming) camp id"
}

function do_server {
  for server in $DOLIST ; do
    echo
    echo "$server: $@"
    echo -n "$server: "
    ssh master@vs${server}.ilp-agency.ru "$@"
  done
}

echo $@
while [ $# -gt 0 ]; do
 case "$1" in
    -h|--help)
     show_help
     exit 0
    ;;
    -s|--slave)
        arg_s=1
        arg_c=0
    ;;
    -c|--command)
        arg_s=0
        arg_c=1
    ;;
    *)
        if [ $arg_s -eq 1 ]; then
            argv_s=$argv_s" "$1;
        fi
        if [ $arg_c -eq 1 ]; then
            argv_c=$argv_c" "$1;
        fi
    ;;
 esac
 shift
done

DOLIST=""
QLIST=""

if [ "$argv_s" == " all" ]; then
  DOLIST=$SENDERS
else
  for x in $argv_s; do
    for y in $SENDERS 14; do
      if [ "$x" == "$y" ]; then
        DOLIST=$DOLIST" "$x
      fi
    done
  done
fi

if [ -z "$DOLIST" ]; then
  show_help
  exit 1
fi

eval set -- "$argv_c"
echo "$@"
case $1 in
 remove_to|remove_from|remove_camp)
   remove_command=$1
   shift
     for y in $QUEUE; do
       if [ "$1" == "$y" ]; then
          QLIST=$y
       fi
     done
 ;;
 start|stop|restart|status)
   postfix_command=$1
 ;;
esac

if [ -n "$postfix_command" ]; then
  do_server "sudo /etc/init.d/postfix $postfix_command"
  exit 0
fi


if [ -z "$QLIST" ]; then
  show_help
  exit 1
fi

shift

for x in $@; do
  do_server "sudo /etc/postfix/manage.sh $remove_command $QLIST $x"
done
