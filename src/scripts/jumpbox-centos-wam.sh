#!/bin/bash

# Custom logging with time so we can easily relate running times, also log to separate file so order is guaranteed.
# The Script extension output the stdout/err buffer in intervals with duplicates.
log()
{
    echo \[$(date +%d%m%Y-%H:%M:%S)\] "$1"
    echo \[$(date +%d%m%Y-%H:%M:%S)\] "$1" >> /var/log/arm-install.log
}

log "Begin execution of jumpbox watchmaker script extension on ${HOSTNAME}"
START_TIME=$SECONDS

# Set Static DNS after cluster startup but before WAM run for domain join
# script contents to be modified by arm template before execution
set_static_dns()
{
  bash set-static-dns.sh
}

watchmaker_hardening()
{
    log "[watchmaker_hardening] running watchmaker for hardening"
    yum -y install epel-release 
    # Install pip
    yum -y --enablerepo=epel install python-pip wget 
    # Install Python 3
    yum -y install python3
    # Install setup dependencies for python 2.x (removed ver dep for pip, others from readthedocs re 2.6, not sure if applicable to 2.7)
    python3 -m pip install --upgrade pip wheel setuptools
    # Install Watchmaker
    python3 -m pip install --upgrade watchmaker 
    # Setup terminal support for UTF-8
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    # Run Watchmaker
    watchmaker --no-reboot --log-level debug --log-dir=/var/log/watchmaker --config=/usr/local/lib/python3.6/site-packages/watchmaker/static/config.yaml
    if [ $? -ne 0 ]; then
        log "watchmaker didn't run correctly"
    else
        log "[watchmaker_hardening] disabling fips mode for azure linux agent and extensions"
        salt-call --local ash.fips_disable
    fi
}

update_and_reboot_in_2_min()
{
    log "[update_and_reboot_in_2_min] prep for yum update"
    (
        printf "yum -y update\n"
        printf "shutdown -r now\n"
    ) > /root/update.sh
    chmod 700 /root/update.sh
    yum -y install at
    service atd start
    log "[update_and_reboot_in_2_min] run yum update in 2 min and then reboot"
    at now + 2 minutes -f /root/update.sh
}

#########################
# Installation sequence
#########################

set_static_dns

watchmaker_hardening

update_and_reboot_in_2_min

ELAPSED_TIME=$(($SECONDS - $START_TIME))
PRETTY=$(printf '%dh:%dm:%ds\n' $(($ELAPSED_TIME/3600)) $(($ELAPSED_TIME%3600/60)) $(($ELAPSED_TIME%60)))

log "End execution of jumpbox watchmaker script extension on ${HOSTNAME} in ${PRETTY}"
exit 0
