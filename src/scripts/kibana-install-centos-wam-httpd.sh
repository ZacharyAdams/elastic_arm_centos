#!/bin/bash

# License: https://github.com/elastic/azure-marketplace/blob/master/LICENSE.txt
#
# Trent Swanson (Full Scale 180 Inc)
# Martijn Laarman, Greg Marzouka, Russ Cam (Elastic)
# Contributors
#

#########################
# HELP
#########################

export DEBIAN_FRONTEND=noninteractive

help()
{
    echo "This script installs kibana on a dedicated VM in the elasticsearch ARM template cluster"
    echo ""
    echo "Options:"
    echo "    -n      elasticsearch cluster name"
    echo "    -v      kibana version e.g 6.4.1"
    echo "    -u      elasticsearch url e.g. http://10.0.0.4:9200"
    echo "    -l      install X-Pack plugin (<6.3.0) or apply trial license for Platinum features (6.3.0+)"
    echo "    -S      kibana password"
    echo "    -C      kibana cert to encrypt communication between the browser and Kibana"
    echo "    -K      kibana key to encrypt communication between the browser and Kibana"
    echo "    -P      kibana key passphrase to decrypt the private key (optional as the key may not be encrypted)"
    echo "    -Y      <yaml\nyaml> additional yaml configuration"
    echo "    -H      base64 encoded PKCS#12 archive (.p12/.pfx) containing the key and certificate used to secure Elasticsearch HTTP layer"
    echo "    -G      Password for PKCS#12 archive (.p12/.pfx) containing the key and certificate used to secure Elasticsearch HTTP layer"
    echo "    -V      base64 encoded PKCS#12 archive (.p12/.pfx) containing the CA key and certificate used to secure Elasticsearch HTTP layer"
    echo "    -J      Password for PKCS#12 archive (.p12/.pfx) containing the CA key and certificate used to secure Elasticsearch HTTP layer"
    echo "    -U      Public domain name (and optional port) for this instance of Kibana to configure SAML Single-Sign-On"
    echo "    -a      install and configure httpd listening on 443 using self signed certificate as reverse proxy to kibana port 5601"
    echo "    -c      url to ldaps public certificate (.cer) to use for httpd authentication, required if selecting -a"
    echo "    -e      url environment content file to use for httpd authentication, required if selecting -a"
    echo "    -g      ldap dn of group of users to be granted access to kibana via httpd, required if selecting -a"
    echo "    -h      view this help content"
}

# Custom logging with time so we can easily relate running times, also log to separate file so order is guaranteed.
# The Script extension output the stdout/err buffer in intervals with duplicates.
log()
{
    echo \[$(date +%d%m%Y-%H:%M:%S)\] "$1"
    echo \[$(date +%d%m%Y-%H:%M:%S)\] "$1" >> /var/log/arm-install.log
}

log "Begin execution of Kibana script extension on ${HOSTNAME}"
START_TIME=$SECONDS

#########################
# Preconditions
#########################

if [ "${UID}" -ne 0 ];
then
    log "Script executed without root permissions"
    echo "You must be root to run this program." >&2
    exit 3
fi

#########################
# Parameter handling
#########################

#Script Parameters
CLUSTER_NAME="elasticsearch"
KIBANA_VERSION="6.4.1"
#Default internal load balancer ip
ELASTICSEARCH_URL="http://10.0.0.4:9200"
INSTALL_XPACK=0
USER_KIBANA_PWD="changeme"
SSL_CERT=""
SSL_KEY=""
SSL_PASSPHRASE=""
YAML_CONFIGURATION=""
HTTP_CERT=""
HTTP_CERT_PASSWORD=""
HTTP_CACERT=""
HTTP_CACERT_PASSWORD=""
SAML_SP_URI=""
APACHE_LDAPS_CERT=""
APACHE_ENV_CONTENT_URL=""
APACHE_LDAP_GROUP_DN=""

#Loop through options passed
while getopts :n:v:u:S:C:K:P:Y:H:G:V:J:U:c:e:g:lah optname; do
  log "Option $optname set"
  case $optname in
    n) #set cluster name
      CLUSTER_NAME="${OPTARG}"
      ;;
    v) #kibana version number
      KIBANA_VERSION="${OPTARG}"
      ;;
    u) #elasticsearch url
      ELASTICSEARCH_URL="${OPTARG}"
      ;;
    S) #security kibana pwd
      USER_KIBANA_PWD="${OPTARG}"
      ;;
    l) #install X-Pack
      INSTALL_XPACK=1
      ;;
    C) #kibana ssl cert
      SSL_CERT="${OPTARG}"
      ;;
    K) #kibana ssl key
      SSL_KEY="${OPTARG}"
      ;;
    P) #kibana ssl key passphrase
      SSL_PASSPHRASE="${OPTARG}"
      ;;
    H) #Elasticsearch certificate
      HTTP_CERT="${OPTARG}"
      ;;
    G) #Elasticsearch certificate password
      HTTP_CERT_PASSWORD="${OPTARG}"
      ;;
    V) #Elasticsearch CA certificate
      HTTP_CACERT="${OPTARG}"
      ;;
    J) #Elasticsearch CA certificate password
      HTTP_CACERT_PASSWORD="${OPTARG}"
      ;;
    U) #Service Provider URI
      SAML_SP_URI="${OPTARG}"
      ;;
    Y) #kibana additional yml configuration
      YAML_CONFIGURATION="${OPTARG}"
      ;;
    a) #configure httpd
      CONF_APACHE_HTTPD=1
      ;;
    c) #url to ldaps public cert for httpd auth
      APACHE_LDAPS_CERT=${OPTARG}
      ;;
    e) #environment content for httpd
      APACHE_ENV_CONTENT_URL=${OPTARG}
      ;;
    g) #ldap group configured to auth to httpd
      APACHE_LDAP_GROUP_DN=${OPTARG}
      ;;
    h) #show help
      help
      exit 2
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

#########################
# Parameter state changes
#########################

log "Installing Kibana $KIBANA_VERSION for Elasticsearch cluster: $CLUSTER_NAME"
log "Installing X-Pack plugins is set to: $INSTALL_XPACK"
log "Kibana will talk to Elasticsearch over $ELASTICSEARCH_URL"

#httpd parameter validation
if [[ "${CONF_APACHE_HTTPD}" == 1 ]]; then
    if [ -z "${APACHE_LDAPS_CERT}" ]; then
        echo "ERROR-Attempting to configure apache httpd, but did not provide ldaps public cert"
        exit 1
    fi
    if [ -z "${APACHE_ENV_CONTENT_URL}" ]; then
        echo "ERROR-Attempting to configure apache httpd, but did not provide url to env content"
        exit 1
    fi
    if [ -z "${APACHE_LDAP_GROUP_DN}" ]; then
        echo "ERROR-Attempting to configure apache httpd, but did not provide dn to ldap group"
        exit 1
    fi
fi 

#########################
# Installation steps as functions
#########################

random_password()
{ 
  < /dev/urandom tr -dc '!@#$%_A-Z-a-z-0-9' | head -c${1:-64}
  echo
}

install_kibana()
{
    local PACKAGE="kibana-$KIBANA_VERSION-x86_64.rpm"
    local ALGORITHM="512"
    #Removing check because will always be above 6
    #if dpkg --compare-versions "$KIBANA_VERSION" "lt" "5.6.2"; then
    #  ALGORITHM="1"
    #fi

    local SHASUM="$PACKAGE.sha$ALGORITHM"
    local DOWNLOAD_URL="https://artifacts.elastic.co/downloads/kibana/$PACKAGE?ultron=msft&gambit=azure"
    local SHASUM_URL="https://artifacts.elastic.co/downloads/kibana/$SHASUM?ultron=msft&gambit=azure"

    log "[install_kibana] download Kibana $KIBANA_VERSION"
    wget --retry-connrefused --waitretry=1 -q "$SHASUM_URL" -O $SHASUM
    local EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        log "[install_kibana] error downloading Kibana $KIBANA_VERSION sha$ALGORITHM checksum"
        exit $EXIT_CODE
    fi
    log "[install_kibana] download location $DOWNLOAD_URL"
    wget --retry-connrefused --waitretry=1 -q "$DOWNLOAD_URL" -O $PACKAGE
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        log "[install_kibana] error downloading Kibana $KIBANA_VERSION"
        exit $EXIT_CODE
    fi
    log "[install_kibana] downloaded Kibana $KIBANA_VERSION"

    # earlier sha files do not contain the package name. add it
    grep -q "$PACKAGE" $SHASUM || sed -i "s/.*/&  $PACKAGE/" $SHASUM

    shasum -a $ALGORITHM -c $SHASUM
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
        log "[install_kibana] error validating checksum for Kibana $KIBANA_VERSION"
        exit $EXIT_CODE
    fi

    log "[install_kibana] installing Kibana $KIBANA_VERSION"
    rpm --install $PACKAGE
    log "[install_kibana] installed Kibana $KIBANA_VERSION"
}

## Security
##----------------------------------

configure_kibana_yaml()
{
    local KIBANA_CONF=/etc/kibana/kibana.yml
    local SSL_PATH=/etc/kibana/ssl
    # backup the current config
    mv $KIBANA_CONF $KIBANA_CONF.bak

    log "[configure_kibana_yaml] Configuring kibana.yml"

    # set the elasticsearch URL
    echo "elasticsearch.url: \"$ELASTICSEARCH_URL\"" >> $KIBANA_CONF
    echo "server.host:" $(hostname -I) >> $KIBANA_CONF
    # specify kibana log location
    echo "logging.dest: /var/log/kibana.log" >> $KIBANA_CONF
    touch /var/log/kibana.log
    chown kibana: /var/log/kibana.log

    # set logging to silent by default
    echo "logging.silent: true" >> $KIBANA_CONF

    # install x-pack
    if [ ${INSTALL_XPACK} -ne 0 ]; then
      echo "elasticsearch.username: kibana" >> $KIBANA_CONF
      echo "elasticsearch.password: \"$USER_KIBANA_PWD\"" >> $KIBANA_CONF

      local ENCRYPTION_KEY=$(random_password)
      echo "xpack.security.encryptionKey: \"$ENCRYPTION_KEY\"" >> $KIBANA_CONF
      log "[configure_kibana_yaml] X-Pack Security encryption key generated"
      ENCRYPTION_KEY=$(random_password)
      echo "xpack.reporting.encryptionKey: \"$ENCRYPTION_KEY\"" >> $KIBANA_CONF
      log "[configure_kibana_yaml] X-Pack Reporting encryption key generated"

      #if dpkg --compare-versions "$KIBANA_VERSION" "lt" "6.3.0"; then
      #  log "[configure_kibana_yaml] Installing X-Pack plugin"
      #  /usr/share/kibana/bin/kibana-plugin install x-pack
        log "[configure_kibana_yaml] Installed X-Pack plugin"
      #fi
    fi

    # configure HTTPS if cert and private key supplied
    if [[ -n "${SSL_CERT}" && -n "${SSL_KEY}" ]]; then
      [ -d $SSL_PATH ] || mkdir -p $SSL_PATH
      log "[configure_kibana_yaml] Save kibana cert to file"
      echo ${SSL_CERT} | base64 -d | tee $SSL_PATH/kibana.crt
      log "[configure_kibana_yaml] Save kibana key to file"
      echo ${SSL_KEY} | base64 -d | tee $SSL_PATH/kibana.key

      log "[configure_kibana_yaml] Configuring SSL/TLS to Kibana"
      echo "server.ssl.enabled: true" >> $KIBANA_CONF
      echo "server.ssl.key: $SSL_PATH/kibana.key" >> $KIBANA_CONF
      echo "server.ssl.certificate: $SSL_PATH/kibana.crt" >> $KIBANA_CONF
      if [[ -n "${SSL_PASSPHRASE}" ]]; then
          echo "server.ssl.keyPassphrase: \"$SSL_PASSPHRASE\"" >> $KIBANA_CONF
      fi
      log "[configure_kibana_yaml] Configured SSL/TLS to Kibana"
    fi

    # configure HTTPS communication with Elasticsearch if cert supplied and x-pack installed.
    # Kibana x-pack installed implies it's also installed for Elasticsearch
    if [[ -n "${HTTP_CERT}" || -n "${HTTP_CACERT}" && ${INSTALL_XPACK} -ne 0 ]]; then
      [ -d $SSL_PATH ] || mkdir -p $SSL_PATH

      if [[ -n "${HTTP_CERT}" ]]; then
        # convert PKCS#12 certificate to PEM format
        log "[configure_kibana_yaml] Save PKCS#12 archive for Elasticsearch HTTP to file"
        echo ${HTTP_CERT} | base64 -d | tee $SSL_PATH/elasticsearch-http.p12
        log "[configure_kibana_yaml] Extract CA cert from PKCS#12 archive for Elasticsearch HTTP"
        echo "$HTTP_CERT_PASSWORD" | openssl pkcs12 -in $SSL_PATH/elasticsearch-http.p12 -out $SSL_PATH/elasticsearch-http-ca.crt -cacerts -nokeys -chain -passin stdin

        log "[configure_kibana_yaml] Configuring TLS for Elasticsearch"
        if [[ $(stat -c %s $SSL_PATH/elasticsearch-http-ca.crt 2>/dev/null) -eq 0 ]]; then
            log "[configure_kibana_yaml] No CA cert extracted from HTTP cert. Setting verification mode to none"
            echo "elasticsearch.ssl.verificationMode: none" >> $KIBANA_CONF
        else
            log "[configure_kibana_yaml] CA cert extracted from HTTP PKCS#12 archive. Setting verification mode to certificate"
            echo "elasticsearch.ssl.verificationMode: certificate" >> $KIBANA_CONF
            echo "elasticsearch.ssl.certificateAuthorities: [ $SSL_PATH/elasticsearch-http-ca.crt ]" >> $KIBANA_CONF
        fi

      else

        # convert PKCS#12 CA certificate to PEM format
        local HTTP_CACERT_FILENAME=elasticsearch-http-ca.p12
        log "[configure_kibana_yaml] Save PKCS#12 archive for Elasticsearch HTTP CA to file"
        echo ${HTTP_CACERT} | base64 -d | tee $SSL_PATH/$HTTP_CACERT_FILENAME
        log "[configure_kibana_yaml] Convert PKCS#12 archive for Elasticsearch HTTP CA to PEM format"
        echo "$HTTP_CACERT_PASSWORD" | openssl pkcs12 -in $SSL_PATH/$HTTP_CACERT_FILENAME -out $SSL_PATH/elasticsearch-http-ca.crt -clcerts -nokeys -chain -passin stdin

        log "[configure_kibana_yaml] Configuring TLS for Elasticsearch"
        if [[ $(stat -c %s $SSL_PATH/elasticsearch-http-ca.crt 2>/dev/null) -eq 0 ]]; then
            log "[configure_kibana_yaml] No CA cert extracted from HTTP CA. Setting verification mode to none"
            echo "elasticsearch.ssl.verificationMode: none" >> $KIBANA_CONF
        else
            log "[configure_kibana_yaml] CA cert extracted from HTTP CA PKCS#12 archive. Setting verification mode to full"
            echo "elasticsearch.ssl.verificationMode: full" >> $KIBANA_CONF
            log "[configure_kibana_yaml] Set CA cert in certificate authorities"
            echo "elasticsearch.ssl.certificateAuthorities: [ $SSL_PATH/elasticsearch-http-ca.crt ]" >> $KIBANA_CONF
        fi
      fi
      chown -R kibana: $SSL_PATH
      log "[configure_kibana_yaml] Configured TLS for Elasticsearch"
    fi

    # Configure SAML Single-Sign-On
    if [[ -n "$SAML_SP_URI" && ${INSTALL_XPACK} -ne 0 ]]; then
      log "[configure_kibana_yaml] Configuring Kibana for SAML Single-Sign-On"
      # Allow both saml and basic realms
      echo "xpack.security.authProviders: [ saml,basic ]" >> $KIBANA_CONF
      echo "server.xsrf.whitelist: [ /api/security/v1/saml ]" >> $KIBANA_CONF

      local PROTOCOL="`echo $SAML_SP_URI | grep '://' | sed -e's,^\(.*://\).*,\1,g'`"
      local HOSTNAME_AND_PORT=`echo $SAML_SP_URI | sed -e s,$PROTOCOL,,g`
      local HOSTNAME=`echo $HOSTNAME_AND_PORT | sed -e s,.*@,,g | cut -d: -f1`
      local PORT=`echo $HOSTNAME_AND_PORT | grep : | cut -d: -f2`
      if [[ -z "$PORT" ]]; then
        if [[ "$PROTOCOL" == "https://" ]]; then
          PORT=443
        else
          PORT=80
        fi
      fi

      # Kibana is reached through a Public IP address (or a provided URI)
      # so needs to be configured with this for SAML SSO
      echo "xpack.security.public.protocol: ${PROTOCOL%://}" >> $KIBANA_CONF
      echo "xpack.security.public.hostname: \"${HOSTNAME%/}\"" >> $KIBANA_CONF
      echo "xpack.security.public.port: ${PORT%/}" >> $KIBANA_CONF
      log "[configure_kibana_yaml] Configured Kibana for SAML Single-Sign-On"
    fi

    # Additional yaml configuration
    if [[ -n "$YAML_CONFIGURATION" ]]; then
        log "[configure_kibana_yaml] include additional yaml configuration"
        local SKIP_LINES="elasticsearch.username elasticsearch.password "
        SKIP_LINES+="server.ssl.key server.ssl.cert server.ssl.enabled "
        SKIP_LINES+="xpack.security.encryptionKey xpack.reporting.encryptionKey "
        SKIP_LINES+="elasticsearch.url server.host logging.dest logging.silent "
        SKIP_LINES+="elasticsearch.ssl.certificate elasticsearch.ssl.key elasticsearch.ssl.certificateAuthorities "
        SKIP_LINES+="elasticsearch.ssl.ca elasticsearch.ssl.keyPassphrase elasticsearch.ssl.verify "
        SKIP_LINES+="xpack.security.authProviders server.xsrf.whitelist "
        SKIP_LINES+="xpack.security.public.protocol xpack.security.public.hostname xpack.security.public.port "
        local SKIP_REGEX="^\s*("$(echo $SKIP_LINES | tr " " "|" | sed 's/\./\\\./g')")"
        IFS=$'\n'
        for LINE in $(echo -e "$YAML_CONFIGURATION"); do
          if [[ -n "$LINE" ]]; then
              if [[ $LINE =~ $SKIP_REGEX ]]; then
                  log "[configure_kibana_yaml] Skipping line '$LINE'"
              else
                  log "[configure_kibana_yaml] Adding line '$LINE' to $KIBANA_CONF"
                  echo "$LINE" >> $KIBANA_CONF
              fi
          fi
        done
        unset IFS
        log "[configure_kibana_yaml] included additional yaml configuration"
        log "[configure_kibana_yaml] run yaml lint on configuration"
        install_yamllint
        LINT=$(yamllint -d "{extends: relaxed, rules: {key-duplicates: {level: error}}}" $KIBANA_CONF; exit ${PIPESTATUS[0]})
        EXIT_CODE=$?
        log "[configure_kibana_yaml] ran yaml lint (exit code $EXIT_CODE) $LINT"
        if [ $EXIT_CODE -ne 0 ]; then
            log "[configure_kibana_yaml] errors in yaml configuration. exiting"
            exit 11
        fi
    fi
}

install_apt_package()
{
  local PACKAGE=$1
  if [ $(dpkg-query -W -f='${Status}' $PACKAGE 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    log "[install_$PACKAGE] installing $PACKAGE"
    (apt-get -yq install $PACKAGE || (sleep 15; apt-get -yq install $PACKAGE))
    log "[install_$PACKAGE] installed $PACKAGE"
  fi
}

install_yum_package()
{
  local PACKAGE=$1
  QUERY=$(rpm -q $PACKAGE)
  if [[ $QUERY == *$PACKAGE* ]] && [[ $QUERY == *not* ]]; then
    log "[install_$PACKAGE] installing $PACKAGE"
    (yum -y install $PACKAGE || (sleep 15; yum -y install $PACKAGE))
    retVal=$?
    if [ $retVal -ne 0 ]; then
      log "[install_$PACKAGE] failed to install $PACKAGE"
      exit 1
    fi
    log "[install_$PACKAGE] installed $PACKAGE"
  fi
}

#added
install_wget()
{
    install_yum_package wget
}

#added
install_epel()
{
    install_yum_package epel-release
}

#added for shasum
install_perl_Digest_SHA()
{
    install_yum_package perl-Digest-SHA
}

install_yamllint()
{
    install_yum_package yamllint
}

configure_systemd()
{
    log "[configure_systemd] configure systemd to start Kibana service automatically when system boots"
    systemctl daemon-reload
    systemctl enable kibana.service
}

start_systemd()
{
    log "[start_systemd] starting Kibana"
    systemctl start kibana.service
    log "[start_systemd] started Kibana"
}

firewall_ports()
{
    log "[firewall_ports] starting and enabling firewalld"
    systemctl start firewalld.service
    systemctl enable firewalld.service
    if [ ${INSTALL_XPACK} -eq 0 ]; then
      #if not installing xpack only open firewall port for subnet IPs and azure load balancer
      log "[firewall_ports] setting up firewall ports from subnet and azure load balancer source IPs"
      thissubnet=$(ip -o -f inet addr show | awk '/scope global/ {print $4}')
      firewall-cmd --permanent --new-ipset=thissubnetandlb --type=hash:net
      firewall-cmd --permanent --ipset=thissubnetandlb --add-entry=$thissubnet
      firewall-cmd --permanent --ipset=thissubnetandlb --add-entry=168.63.129.16
      firewall-cmd --permanent --zone=public --add-rich-rule='rule family="ipv4" source ipset=thissubnetandlb port protocol="tcp" port="5601" accept'
    else 
      log "[firewall_ports] setting up firewall ports from all source IPs"
      firewall-cmd --zone=public --add-port=5601/tcp
      firewall-cmd --zone=public --permanent --add-port=5601/tcp
    fi

    log "[firewall_ports] firewall ports opened"
}

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

kibana_httpd_self_signed_cert()
{
    #configure self signed ssl cert on httpd for reverse proxy to kibana
    if [ "${CONF_APACHE_HTTPD}" -ne 0 ]; then
        log "[kibana_httpd_self_signed_cert] Configure kibana for httpd reverse proxy using self signed ssl cert"
        bash httpdrevproxyselfsigned.sh -P 5601
        systemctl enable httpd
        #assumes client node also using self signed cert, configuring if switching which port to connect to es on
        echo "elasticsearch.ssl.verify: false" >> /etc/kibana/kibana.yml
    fi
}

kibana_httpd_ldaps_auth()
{
    #configure kibana httpd for ldaps authentication
    if [ "${CONF_APACHE_HTTPD}" -ne 0 ]; then
        log "[kibana_httpd_self_signed_cert] Configure kibana for ldaps authentication"
        bash kibananodeldapsauth.sh -C "${APACHE_LDAPS_CERT}" -E "${APACHE_ENV_CONTENT_URL}" -G "${APACHE_LDAP_GROUP_DN}"
        systemctl enable httpd
        systemctl restart httpd
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

# if kibana is already installed assume this is a redeploy
# change yaml configuration and only restart the server when needed
if systemctl -q is-active kibana.service; then

  configure_kibana_yaml

  # restart kibana if the configuration has changed
  cmp --silent /etc/kibana/kibana.yml /etc/kibana/kibana.yml.bak \
    || systemctl reload-or-restart kibana.service

  exit 0
fi

#log "[apt-get] updating apt-get"
#(apt-get -y update || (sleep 15; apt-get -y update))
#log "[apt-get] updated apt-get"

install_wget

install_epel

install_perl_Digest_SHA

install_kibana

configure_kibana_yaml

firewall_ports

configure_systemd

start_systemd

set_static_dns

watchmaker_hardening

kibana_httpd_self_signed_cert

kibana_httpd_ldaps_auth

update_and_reboot_in_2_min

ELAPSED_TIME=$(($SECONDS - $START_TIME))
PRETTY=$(printf '%dh:%dm:%ds\n' $(($ELAPSED_TIME/3600)) $(($ELAPSED_TIME%3600/60)) $(($ELAPSED_TIME%60)))
log "End execution of Kibana script extension in ${PRETTY}"
