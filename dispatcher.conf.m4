Include conf/server.conf

Listen 8080
Listen 8443


<IfModule disp_apache2.c>
  DispatcherConfig conf/dispatcher.any
  DispatcherLog    logs/dispatcher.log
  DispatcherLogLevel 3
  DispatcherNoServerHeader 0
  DispatcherDeclineRoot 0
  DispatcherUseProcessedURL 0
  DispatcherPassError 0
#  DispatcherKeepAliveTimeout 60
</IfModule>

<Macro RewriteSiteHTML $proto $domain $sitename>
  Substitute "s|/content/$sitename.html|/|in"
  Substitute "s|/content/$sitename|$proto://$domain|in"
</Macro>

<Macro ExclusiveRewrite $prefix $url $target>
  RewriteCond "%{REQUEST_URI}" "$prefix$url(.*)$"
  RewriteRule ^(.*)$ $target [R]
</Macro>

<VirtualHost *:8080>
  ServerName SERVERDNSNAME
  ServerAlias ${serveralias}
DOCROOT

  RewriteEngine on

  Include conf/redirects.conf

  <LocationMatch ".(html|js)$">
    SetOutputFilter SUBSTITUTE

    # Use RewriteSiteHTML http
HTTPREWRITE
  </LocationMatch>

  <Directory />
    <IfModule disp_apache2.c>
      SetHandler dispatcher-handler
    </IfModule>
    Options FollowSymLinks
    AllowOverride None
  </Directory>
  <Location /dispatcher>
    <IfModule disp_apache2.c>
      SetHandler dispatcher-handler
    </IfModule>
    Options FollowSymLinks
    AllowOverride None
    Require all granted
  </Location>
</VirtualHost>

<VirtualHost *:8443>
  ServerName SERVERDNSNAME
  ServerAlias ${serveralias}
DOCROOT

  SSLEngine on
  SSLCertificateFile CERTFILEPATH
  SSLCertificateKeyFile KEYFILEPATH

  RewriteEngine on

  Include conf/redirects.conf

  <LocationMatch ".(html|js)$">
    SetOutputFilter SUBSTITUTE

    # Use RewriteSiteHTML https
HTTPSREWRITE
  </LocationMatch>

  <Directory />
    <IfModule disp_apache2.c>
      SetHandler dispatcher-handler
    </IfModule>
    Options FollowSymLinks
    AllowOverride None
  </Directory>
  <Location /dispatcher>
    <IfModule disp_apache2.c>
      SetHandler dispatcher-handler
    </IfModule>
    Options FollowSymLinks
    AllowOverride None
    Require all granted
  </Location>
</VirtualHost>

<Macro AemDirectory $dirpath>
  <Directory $dirpath>
    Require all granted
  </Directory>
</Macro>

<Macro AemGlobalPath $proto $port $path>
  <Location $path>
    ProxyPass $proto://dispatcher.localhost:$port$path retry=0
    ProxyPassReverse $proto://dispatcher.localhost:$port$path
  </Location>
</Macro>

<Macro AemSite $domain $contentfolder>
  <VirtualHost *:80>
    ServerName $domain
	ServerAlias www.$domain

    ProxyRequests Off
    RewriteEngine On

    ProxyErrorOverride on

    RewriteCond "%{REQUEST_URI}" "^/.html$"
    RewriteRule "^(.*)$" "http://$domain/" [R]

    RewriteCond "%{REQUEST_URI}" "^/$"
    RewriteRule "^(.*)$" "http://dispatcher.localhost:8080/content/$contentfolder.html" [P]

    RewriteCond "%{REQUEST_URI}" "^/content/$contentfolder"
    RewriteRule "^/content/$contentfolder/(.*)$" "http://$domain/$1" [R]

    RewriteCond "%{REQUEST_URI}" ".+/$"
    RewriteRule "^/(.*)[/]*$" "http://$domain/$1.html" [R]

    RewriteCond "%{REQUEST_URI}" !\.[a-zA-Z0-9]*$
    RewriteCond "%{REQUEST_URI}" !^/content/dam
    RewriteRule "^/(.*)[/]*$" "http://$domain/$1.html" [R]

    RewriteCond "%{REQUEST_URI}" "^/.+/.html$"
    RewriteRule "^/(.*)/.html$" "http://$domain/$1.html" [R]

    Header edit Location "^http://dispatcher.localhost:8080/(.*)$" "http://$domain/$1"

    IncludeOptional conf/$domain-http.con[f]

    Use AemGlobalPath http 8080 /apps
    Use AemGlobalPath http 8080 /bin
    Use AemGlobalPath http 8080 /etc
    Use AemGlobalPath http 8080 /libs
    Use AemGlobalPath http 8080 /system
    Use AemGlobalPath http 8080 /content/dam
    Use AemGlobalPath http 8080 /errors

    ErrorDocument 404 /errors/404.html
    ErrorDocument 500 /errors/500.html

    ProxyPass / http://dispatcher.localhost:8080/content/$contentfolder/ retry=0
    ProxyPassReverse / http://dispatcher.localhost:8080/content/$contentfolder/

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
    CustomLog "|/usr/sbin/rotatelogs logs/access_log.$domain.%Y.%m.%d 86400" combined
    ErrorLog "|/usr/sbin/rotatelogs /var/log/error_log.$domain.%Y.%m.%d"
  </VirtualHost>

  <VirtualHost "*:443">
    ServerName $domain
	ServerAlias www.$domain

    SSLEngine on
    SSLProxyEngine on
    SSLCertificateFile CERTPATH
    SSLCertificateKeyFile KEYPATH

    ProxyRequests Off
    RewriteEngine On

    ProxyErrorOverride on

    RewriteCond "%{REQUEST_URI}" "^/.html$"
    RewriteRule "^(.*)$" "https://$domain/" [R]

    RewriteCond "%{REQUEST_URI}" "^/$"
    RewriteRule "^(.*)$" "https://dispatcher.localhost:8443/content/$contentfolder.html" [P]

    RewriteCond "%{REQUEST_URI}" "^/content/$contentfolder"
    RewriteRule "^/content/$contentfolder/(.*)$" "https://$domain/$1" [R]

    RewriteCond "%{REQUEST_URI}" ".+/$"
    RewriteRule "^/(.*)[/]*$" "https://$domain/$1.html" [R]

    RewriteCond "%{REQUEST_URI}" !\.[a-zA-Z0-9]*$
    RewriteCond "%{REQUEST_URI}" !^/content/dam
    RewriteRule "^/(.*)[/]*$" "https://$domain/$1.html" [R]

    RewriteCond "%{REQUEST_URI}" "^/.+/.html$"
    RewriteRule "^/(.*)/.html$" "https://$domain/$1.html" [R]

    Header edit Location "^https://dispatcher.localhost:8443/(.*)$" "https://$domain/$1"

    IncludeOptional conf/$domain-https.con[f]

    Use AemGlobalPath https 8443 /apps
    Use AemGlobalPath https 8443 /bin
    Use AemGlobalPath https 8443 /etc
    Use AemGlobalPath https 8443 /libs
    Use AemGlobalPath https 8443 /system
    Use AemGlobalPath https 8443 /content/dam
    Use AemGlobalPath https 8443 /errors

    ErrorDocument 404 /errors/404.html
    ErrorDocument 500 /errors/500.html

    SSLProxyCheckPeerExpire off
    SSLProxyCheckPeerName off
    SSLProxyCheckPeerCN off
    ProxyPass / https://dispatcher.localhost:8443/content/$contentfolder/ retry=0
    ProxyPassReverse / https://dispatcher.localhost:8443/content/$contentfolder/

    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-agent}i\"" combined
    CustomLog "|/usr/sbin/rotatelogs logs/access_log.$domain.%Y.%m.%d 86400" combined
    ErrorLog "|/usr/sbin/rotatelogs /var/log/error_log.$domain.%Y.%m.%d"
  </VirtualHost>
</Macro>
