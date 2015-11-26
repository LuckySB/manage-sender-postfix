#!/bin/sh

QUEUE="active bounce deferred hold incoming"

case $1 in
  remove_all)
    greparg=""
  ;;
  remove_from)
    greparg="sender: .*@"$3
  ;;
  remove_to)
    greparg="recipient: .*@"$3
  ;;
  remove_camp)
    greparg="X-ILPCRM-CAMPAIGN-ID: "$3
  ;;
  *)
    echo "Usage $0 remove_to|remove_from|remove_camp all|queue_name arg"
    exit 1
esac

if [ "$2" == "all" ]; then
  QLIST=$QUEUE
else
  for x in $QUEUE; do
    if [ "$x" == "$2" ]; then
      QLIST=$x
    fi
  done
fi

if [ -z greparg ]; then
  for x in $QLIST; do
    rm -rf /var/spool/postfix/$x/
  done
else
  for x in $QLIST; do
    for y in `/usr/bin/find /1/var/spool/$x -type f`; do
      T=`/usr/sbin/postcat $y | /bin/grep -iE "$greparg" | wc -l`
      if [ $T -ne 0 ]; then
        echo $y
        rm -f $y
        if [ "$x" == "deferred" ]; then
          tt="/var/spool/postfix/"`basename $y`
          rm -f $tt
        fi
      fi
    done
  done
fi

OUT=`service postfix status | grep stopped | wc -l`
if [ $OUT -eq 0 ]; then
  service postfix restart
fi

[root@vs15.ilp-agency.ru /etc/postfix]# cat manage1.sh
#!/bin/sh

QUEUE="active bounce deferred hold incoming"

case $1 in
  remove_all)
    greparg=""
  ;;
  remove_from)
    greparg="sender: .*@"$3
  ;;
  remove_to)
    greparg="recipient: .*@"$3
  ;;
  remove_camp)
    greparg="X-ILPCRM-CAMPAIGN-ID: "$3
  ;;
  *)
    echo "Usage $0 remove_to|remove_from|remove_camp all|queue_name arg"
    exit 1
esac

if [ "$2" == "all" ]; then
  QLIST=$QUEUE
else
  for x in $QUEUE; do
    if [ "$x" == "$2" ]; then
      QLIST=$x
    fi
  done
fi

if [ -z greparg ]; then
  for x in $QLIST; do
    rm -rf /var/spool/postfix/$x/
  done
else
  for x in $QLIST; do
    for y in `/usr/bin/find /1/var/spool/$x -type f`; do
      T=`/usr/sbin/postcat $y | /bin/grep -iE "$greparg" | wc -l`
      if [ $T -ne 0 ]; then
        echo $y
        rm -f $y
        if [ "$x" == "deferred" ]; then
          tt="/var/spool/postfix/"`basename $y`
          rm -f $tt
        fi
      fi
    done
  done
fi

OUT=`service postfix status | grep stopped | wc -l`
if [ $OUT -eq 0 ]; then
  service postfix restart
fi
