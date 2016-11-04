#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "Du musst root sein"
    exit 1
fi

# Prüfe ob /etc/hosts.d und /etc/hosts.d/00-hosts existieren
( [ -d /etc/hosts.d ] && [ -f /etc/hosts.d/00-hosts ] ) || \
    ( echo Bitte lese die Anweisungen unter \
    https://gist.github.com/ajacobsen/661af20d1b892fdbe33f08708f7ef03f)

# Download der hosts Dateien
# Entfernen von carriage returns
# Entfernen von localhost und broadcast Adressen
# Entfernen von allen Kommentaren
# Entfernen aller Zeilen, die nicht mit 0.0.0.0 beginnen
# Entfernen von Leerzeilen
wget -qO - http://winhelp2002.mvps.org/hosts.txt| \
    sed -e 's/\r//' -e '/^127/d' -e '/^255.255.255.255/d' -e '/::1/d' -e 's/#.*$//' -e '/^0.0.0.0/!d' -e '/^$/d'|\
    sort -u >/etc/hosts.d/10-mvpblocklist || \
    echo "WARNUNG! Download von http://winhelp2002.mvps.org/hosts.txt fehlgeschlagen"
wget -qO - http://someonewhocares.org/hosts/zero/hosts| \
    sed -e 's/\r//' -e '/^127/d' -e '/^255.255.255.255/d' -e '/::1/d' -e 's/#.*$//' -e '/^0.0.0.0/!d' -e '/^$/d'|\
    sort -u >/etc/hosts.d/20-some1whocaresblocklist || \
    echo "WARNUNG! Download von http://someonewhocares.org/hosts/zero/hosts fehlgeschlagen"

printf "# DO NOT EDIT THIS FILE\\nIt is automaticly generated by block-tracker from the files in /etc/hosts.d/\\nYour original hosts file can be found at /etc/hosts.d/00-hosts you should make any changes there" > /etc/hosts
# Verbinde Datein in /etc/hosts.d/ zu einer /etc/hosts
for f in /etc/hosts.d/*; do
	echo >> /etc/hosts
	echo "# ${f} #" >> /etc/hosts 
    cat "${f}" >> /etc/hosts
done

echo Done