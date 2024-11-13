#!/bin/sh

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

echo -n "Enter T (must be between 1-4): "
read T
echo -n "Enter Group number (must be between 1-6): "
read G

echo "T: $T"
echo "G: $G"

check_user_input() {
    case $T in
        ''|*[!0-9]*) 
            echo "Error: Please enter valid numbers."
            exit 1
            ;;
    esac

    case $G in
        ''|*[!0-9]*) 
            echo "Error: Please enter valid numbers."
            exit 1
            ;;
    esac

    if [ "$T" -lt 1 ] || [ "$T" -gt 4 ] || [ "$G" -lt 1 ] || [ "$G" -gt 6 ]; then
        echo "Error: T must be between 1 and 4, and G must be between 1 and 6."
        exit 1
    fi

    echo "Input validation successful."
}

create_users() {
    pass="rc3!ficha04"

    # Install shadow package for useradd and groupadd commands
    apk add shadow

    # User creation
    for user in user1 user2 user3 user4 backup-operator; do
        useradd -m "$user"
        echo "$user:$pass" | chpasswd
        passwd -e "$user"
    done

    # Groups creation
    for group in grp1 grp2 grp3 grp4; do
        groupadd "$group"
    done

    # Link users to groups
    usermod -aG grp1 user1
    usermod -aG grp1 user4
    usermod -aG grp2 user2
    usermod -aG grp2 user4
    usermod -aG grp3 user3
    usermod -aG grp3 user4
    usermod -aG grp4 user4
}

install_configure_acl() {
    apk add acl
    mount -o remount,acl /
}

create_directories() {
    mkdir -p /share/docs
    mkdir -p /share/public
    mkdir -p /share/backups
    mkdir -p /share/manuais/historia

    touch /share/manuais/historia/genesis.txt
    for dir in /share/docs /share/public /share/backups /share/manuais; do
        touch "$dir/fich1.txt"
    done
    touch /share/public/fich2.txt
    touch /share/manuais/fich3.txt
}

install_configure_file_server() {
    SERIAL=$(date +%Y%m%d%H%M%S)
    REFRESH=604800   # 1 week
    RETRY=86400      # 1 day
    EXPIRE=2419200   # 4 weeks
    MINIMUM=604800   # 1 week

    apk add bind samba

    # Create BIND zone file
    echo "
\$TTL 2d
\$ORIGIN rc3${T}${G}.test.
@   IN SOA ns1.rc3${T}${G}.test. hostmaster.rc3${T}${G}.test. (
    $SERIAL ; serial
    $REFRESH    ; refresh
    $RETRY  ; retry
    $EXPIRE ; expire
    $MINIMUM    ; minimum caching
)
    IN  NS  ns1.rc3${T}${G}.test.
    IN  MX  10  mail.rc3${T}${G}.test.

ns1     IN  A   172.20.${T}${G}.1
mail    IN  A   192.168.1${T}${G}.125
app     IN  A   192.168.1${T}${G}.21${G}
webserver   IN  A   192.168.1${T}${G}.21${G}
r1      IN  A   172.20.${T}${G}.2
file-server IN A 172.20.${T}${G}.1
" >/etc/bind/rc3${T}${G}.test

    # Add zone to named.conf
    cat <<EOF >>/etc/bind/named.conf
zone "rc3${T}${G}.test" {
    type master;
    file "/etc/bind/rc3${T}${G}.test";
};
EOF

    # Start and enable BIND service
    rc-update add named default
    rc-service named restart

    # Create Samba configuration
    cat <<EOF >/etc/samba/smb.conf
[global]
   unix password sync = yes
   workgroup = Turno ${T} Grupo ${G}
   server string = Linux Samba %h
   map to guest = Bad User
   hostname lookups = no
   syslog = 1
   server role = standalone
   case sensitive = no
   preserve case = yes
   log file = /usr/local/samba/var/log.%m
   max log size = 50
   dns proxy = no

[homes]
   comment = Home Directories
   browsable = no
   writable = yes

[printers]
   comment = All Printers
   path = /usr/spool/samba
   browsable = no
   guest ok = no
   writable = no
   printable = yes
EOF

    # Start and enable Samba services
    rc-update add samba default
    rc-service samba restart
}

configure_permissions() {
    setfacl -m g:grp1:rw /share/docs
    setfacl -m u:user2:rwx /share/docs
    setfacl -m u:user4:rwx /share/docs
    setfacl -m u:user3:--- /share/docs

    setfacl -m u:user1:rw /share/public
    setfacl -m u:user4:rw /share/public

    setfacl -m u:user4:rw /share/manuais
    setfacl -m u:user4:rw /share/backups
    setfacl -m u:backup-operator:rwx /share/backups
    setfacl -m g:grp1:r-- /share/public
}

# Main script execution
apk update
apk add acl samba bind

check_user_input || { echo "Input validation failed"; exit 1; }
create_users || { echo "User creation failed"; exit 1; }
install_configure_acl || { echo "Installation and Configuration of ACL failed"; exit 1; }
create_directories || { echo "Directory creation failed"; exit 1; }
install_configure_file_server || { echo "Configuration and Installation of file server failed"; exit 1; }
configure_permissions || { echo "Permission configuration failed"; exit 1; }

echo "Setup completed successfully."
