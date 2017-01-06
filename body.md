* <a href="#user-content-german">README in German</a>

## English
This script blocks advertisements by extending /etc/hosts to block specific websites.

Execute following command to install block-tracker.
```
wget -O block-tracker-setup.sh https://raw.githubusercontent.com/ajacobsen/block-tracker/v0.0.4/block_tracker.sh && sudo bash block-tracker-setup.sh --install && rm block-tracker-setup.sh
```
This will create `/usr/local/etc/block-tracker/hosts/` directory and
copies `/etc/hosts` to `/usr/local/etc/block-tracker/hosts/system.hosts`.

*Note*: `block-tracker` will concatenate \*.hosts files from `/usr/local/etc/block-tracker/hosts/` into one file `/etc/hosts`
which causes `/etc/hosts` to be overwritten every time when `block-tacker` is invoked.
To add additional local entries which will not be overwritten you have to add them in `/usr/local/etc/block-tracker/hosts/system.hosts`
or you create an addional file called, e.g. `/usr/local/etc/block-tracker/hosts/name.hosts`

To uninstall `block-tracker` just invoke
```
sudo block-tracker --uninstall
```
During uninstall `/usr/local/etc/block-tracker/hosts/system.hosts` will be copied to `/etc/hosts` and directory `/usr/local/etc/block-tracker/` and file `/usr/local/bin/block-tracker` will be deleted.

After installation you have to invoke
```
sudo block-tracker --run
```
at least once. This will download the lists with bad domains (blocklists), save them to `/usr/local/etc/block-tracker/hosts/` and enable blocking of all those domains.

To temporarily disable `block-tracker` invoke
```
sudo block-tracker --disable
```
To re-enable `block-tracker` invoke
```
sudo block-tracker --enable
```
or
```
sudo block-tracker --run
```
The difference is, that `--enable` does not download the blocklists.
You should prefer `--enable` and use `--run` only if you want to get the latest version of the blocklists.

To check if `block-tracker` is enabled/disabled invoke
```
sudo block-tracker --status
```

To update `block-tracker` to the latest stable release invoke
```
sudo block-tracker --update
```

`block-tracker --help` shows a brief description of all options

Configuration and Usage of the domain filter (opition --filter and --filter-test):

*TODO: document -f/-F*

`block-tracker` uses following lists:
* http://someonewhocares.org/hosts/
* http://winhelp2002.mvps.org/
* http://sysctl.org
* http://pgl.yoyo.org

---

## German
Dieses Script blockt mittels hosts Dateien u.a. Werbung.

Zum Installieren, einfach folgenden Befehl ausführen:
```
wget -O block-tracker-setup.sh https://raw.githubusercontent.com/ajacobsen/block-tracker/v0.0.4/block_tracker.sh && sudo bash block-tracker-setup.sh --install && rm block-tracker-setup.sh
```
Das erstellt den Ordner `/usr/local/etc/block-tracker/hosts/` und kopiert die Datei `/etc/hosts` nach `/usr/local/etc/block-tracker/hosts/system.hosts`

*Hinweis:* `block-tracker` fügt dann alle \*.hosts Dateien in `/usr/local/etc/block-tracker/hosts/` zu einer `/etc/hosts`
zusammen und dadurch wird die Datei `/etc/hosts` bei jedem Aufruf überschrieben.
Um eigene Einträge aufzunehmen die nicht überschrieben werden, müssen diese entweder in `/usr/local/etc/block-tracker/hosts/system.hosts`
eingetragen werden oder man erstellt eine weitere Datei und macht
dort die gewünschten Einträge. z.B. `/usr/local/etc/block-tracker/hosts/name.hosts`

Möchte man das Skript wieder deinstallieren, genügt dieser Befehl:
```
sudo block-tracker --uninstall
```
Dabei wird die Datei `/usr/local/etc/block-tracker/hosts/system.hosts` wieder nach `/etc/hosts` kopiert und das Verzeichnis `/usr/local/etc/block-tracker/` sowie die Datei `/usr/local/bin/block-tracker` gelöscht.

Nach der Installation muss
```
sudo block-tracker --run
```
ausgeführt werden, um die Blocklisten runterzuladen, in `/usr/local/etc/block-tracker/hosts/` zu speichern

Um `block-tracker` vorübergehend zu deaktivieren, benutze
```
sudo block-tracker --disable
```
Um `block-tracker` wieder zu aktivieren, benutze
```
sudo block-tracker --enable
```
oder
```
sudo block-tracker --run
```
Der Unterschied ist, dass `--enable` die Blocklisten nicht (erneut) herunterlädt.
Man sollte `--enable` bevorzugen, so lange man nicht die Blocklisten aktualisieren möchte.

Um zu prüfen, ob `block-tracker` aktiviert/deaktiviert ist, benutze
```
sudo block-tracker --status
```
Um `block-tracker` auf die neueste stabile Version zu aktualisieren benutze
```
sudo block-tracker --update
```

`block-tracker --help` zeigt eine kurze Beschreibung aller Optionen.

Konfiguration und Benutzung des Domain-Filter (--filter and --filter-test):

*TODO: dokumentieree -f/-F*

`block-tracker` benutzt diese Listen:
* http://someonewhocares.org/hosts/
* http://winhelp2002.mvps.org/
* http://sysctl.org
* http://pgl.yoyo.org
