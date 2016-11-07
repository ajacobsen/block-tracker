* <a href="#english">Read README in English</a><br/>
* <a href="#german">Read README in German</a>

<a name="english"></a>
## English
This script blocks advertisements by extending the /etc/hosts to block specific websites.

Execute following command to install block-tracker.
```
wget -O block-tracker-setup.sh https://raw.githubusercontent.com/ajacobsen/block-tracker/master/block_tracker_setup.sh && sudo bash block-tracker-setup.sh
```

Now invoke 
```
sudo block-tracker 
```
to install block-tracker which will create `/etc/hosts.d/` directory and 
copies `/etc/hosts` to `/etc/hosts.d/00-hosts`

*Note:* `block-tracker` will concatenate all files from `/etc/hosts.d/` into one file `/etc/hosts`
which causes `/etc/hosts` to be overwritten every time when `block-tacker` is invoked.
To add additional local entries which will not be overwritten you have to add them in `/etc/hosts.d/00-hosts`
or you create an addional file called `/etc/hosts.d/01-myhost`
Leading numbers (00, 01, ..) define the sequence the files will be concatenated.

To uninstall `block-tracker` just invoke
```
wget -O block-tracker-setup.sh https://raw.githubusercontent.com/ajacobsen/block-tracker/master/block_tracker_setup.sh && sudo bash block-tracker-setup.sh --uninstall
```
During uninstall `/etc/hosts.d/00-hosts` will be copied to `/etc/hosts` and directory `/etc/hosts.d/` and file `/usr/local/bin/block-tracker` will be deleted.

`block-tracker` uses follwoing lists:
* http://someonewhocares.org/hosts/
* http://winhelp2002.mvps.org/

---

<a name="german"></a>
## German
Dieses Script blockt vermittels hosts Dateien u.a. Werbung.

Zum Installieren, einfach folgenden Befehl ausführen:
```
wget -O block-tracker-setup.sh https://raw.githubusercontent.com/ajacobsen/block-tracker/master/block_tracker_setup.sh && sudo bash block-tracker-setup.sh
```

Danach kann das Skript mittels
```
sudo block-tracker 
```
aufgerufen werden.

Das Installationsskript erstellt den Ordner `/etc/hosts.d/` und kopiert die Datei `/etc/hosts` nach `/etc/hosts.d/00-hosts`

*Hinweis:* `block-tracker` fügt dann alle Dateien in `/etc/hosts.d/` zu einer `/etc/hosts`
zusammen und dadurch wird die Datei `/etc/hosts` bei jedem Aufruf überschrieben. 
Um eigene Einträge aufzunehmen die nicht überschrieben werden, müssen diese entweder in `/etc/hosts.d/00-hosts`
eingetragen werden oder man erstellt eine weitere Datei und macht
dort die gewünschten Einträge. Z.B. `/etc/hosts.d/01-meinedatei`
Durch die führenden Zahlen (00, 01, ..) wird bestimmt in welcher Reihenfolge
die Dateien zusammengesetzt werden.

Möchte man das Skript wieder deinstallieren, genügt dieser Befehl:
```
wget -O block-tracker-setup.sh https://raw.githubusercontent.com/ajacobsen/block-tracker/master/block_tracker_setup.sh && sudo bash block-tracker-setup.sh --uninstall
```
Dabei wird die Datei `/etc/hosts.d/00-hosts` wieder nach `/etc/hosts` kopiert und das Verzeichnis `/etc/hosts.d/` sowie die Datei `/usr/local/bin/block-tracker` gelöscht.

`block-tracker` benutzt diese Listen:
* http://someonewhocares.org/hosts/
* http://winhelp2002.mvps.org/

