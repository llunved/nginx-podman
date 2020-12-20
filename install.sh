#!/bin/bash


set -x

SERVICE=$IMAGE

env

# Make sure the host is mounted
if [ ! -d /host/etc -o ! -d /host/proc -o ! -d /host/var/run ]; then
	    echo "Host file system is not mounted at /host" >&2
	        exit 1
fi

# Make sure that we have required directories in the host
for CUR_DIR in /host${LOGDIR}/${NAME} /host${DATADIR}/${NAME} /host${CONFDIR}/${NAME} ; do
    if [ ! -d $CUR_DIR ]; then
        mkdir -p $CUR_DIR
	if [ "$CUR_DIR" == "/host${CONFDIR}/${NAME}" ] ; then
	    cp -Rv ${CONFDIR}/${NAME}.default/* /host${CONFDIR}/${NAME}/
	elif [ "$CUR_DIR" == "/host${DATADIR}/${NAME}" ] ; then
	    cp -Rv ${DATADIR}/${NAME}.default/* /host${DATADIR}/${NAME}/
	fi
        chmod 775 $CUR_DIR
	chgrp -R 0 $CUR_DIR
    fi
done    


chroot /host /usr/bin/podman create --name ${NAME} -p 443:443 -p 80:80 --net=host -v ${DATADIR}/${NAME}:/var/lib/${NAME}:rw,z -v ${CONFDIR}/${NAME}:/etc/${NAME}:rw,z -v ${LOGDIR}/${NAME}:/var/log/${NAME}:rw,z ${IMAGE}
chroot /host sh -c "/usr/bin/podman generate systemd --restart-policy=always -t 1 ${NAME} > /etc/systemd/system/${NAME}.service && systemctl daemon-reload && systemctl enable ${NAME}"
