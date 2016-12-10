#/bin/bash

# associative array which holds for every url the url separated by <TAB> from regex for sed
# TBD: here doc used for now, should be placed in git repo

cat <<END > hostsfiles.list	
	http://winhelp2002.mvps.org/hosts.txt	s/\r// \n /^0/!d \n s/#.*$//
	http://someonewhocares.org/hosts/zero/hosts	/^0/!d \n s/#.*$//
	http://sysctl.org/cameleon/hosts	/^127.0.0.1.*localhost$/d \n s/^127.0.0.1/0.0.0.0/ \n s/[\t]//g \n /^0/!d
	http://pgl.yoyo.org/as/serverlist.php?hostformat=hosts&useip=0.0.0.0&mimetype=plaintext	/^0/!d
END

# TBD: wget hostsfiles.list from git repo

typeset -A LISTs

while IFS=$'\t' read -r url regex; do
	src=${url%%.*}					# extract first qualifier from url to build filename 
	src=${src##*://}
	echo "Retrieving url: $url into $src"
	wget -qO $src $url
	echo "Applying regex $regex on $src into ${src}_clean"
	printf "%b" "${regex}" |sed -f - ${src} > ${src}_clean
done < hostsfiles.list
