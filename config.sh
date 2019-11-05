printf "Configuring dispatcher and macros..."
CERTPATH=$(cat ./tmp/settings.txt | grep '^CERT' | sed 's/^CERT //g')
KEYPATH=$(cat ./tmp/settings.txt | grep '^KEY' | sed 's/^KEY //g')
WWWROOT=$(cat ./tmp/settings.txt | grep '^ROOT' | sed 's/^ROOT //g')
SVRNAME=$(cat ./tmp/settings.txt | grep '^SVR' | sed 's/^SVR //g')
(printf "define(\`HTTPREWRITE',\`" ; cat ./tmp/domainlisting.txt | sed 's/^/    Use RewriteSiteHTML http /g' ; printf "')\n") > ./tmp/dispatcher.m4
(printf "define(\`HTTPSREWRITE',\`" ; cat ./tmp/domainlisting.txt | sed 's/^/    Use RewriteSiteHTML https /g' ; printf "')\n") >> ./tmp/dispatcher.m4
printf "define(\`CERTPATH',\`$CERTPATH')\n" >> ./tmp/dispatcher.m4
printf "define(\`KEYPATH',\`$KEYPATH')\n" >> ./tmp/dispatcher.m4
printf "define(\`DOCROOT',\`  DocumentRoot $WWWROOT')\n" >> ./tmp/dispatcher.m4
printf "define(\`SERVERDNSNAME',\`$SVRNAME')\n" >> ./tmp/dispatcher.m4
cat ./tmp/dispatcher.m4 dispatcher.conf.m4 | m4 > build/dispatcher.conf
printf "done\n"

printf "Configuring sites..."
(printf "define(\`SITEDEFS',\`" ; cat ./tmp/domainlisting.txt | sed 's/^/Use AemSite /g' ; printf "')\n" ) > ./tmp/dispatcher-sites.m4
cat ./tmp/dispatcher-sites.m4 dispatcher-sites.conf.m4 | m4 > build/dispatcher-sites.conf
printf "done\n"
