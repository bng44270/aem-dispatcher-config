# aem-dispatcher-config

This generates configuration files for Apache Web Server to be able function as an Adobe Experience Manager (AEM) Dispatcher.  You will need to load the dispatcher module and manage the ```dispatcher.any``` file on your own, however this will allow you to easily configure multiple sites serve them through Apache.  
  
### Configuration:  
1. Run ```make```
2. Enter the server DNS names/folder.  
  a.  Note that the folder should exist under /content  
  b.  When you're done enter nothing for server and folder to continue
3. Enter the server name that your dispatcher will be accessed with
4. Enter the path to your SSL cert/key files for dispatcher  
  
### Installation:  
1. Copy files into place on the filesystem:
  a. ##-dispatcher*.conf - <APACHE>/conf.d
  b. redirects.conf - <APACHE>/conf
