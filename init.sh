echo "Press <enter> when you're done entering domain/nodes"
domcount="1"
while true; do
	read -p "($domcount) Enter domain: " thisdomain
	read -p "($domcount) Enter node (/content/FOLDERNAME): " thisfolder
	if [ -z "$thisdomain" ] || [ -z "$thisfolder" ]; then
		break
	fi
	printf "$thisdomain $thisfolder\n" >> tmp/domainlisting.txt
	export domcount=$[ $domcount + 1 ]
done

read -p "Enter webroot: " wwwroot
read -p "Enter server name: " servername
read -p "Enter SSL certificate path: " thiscertpath
read -p "Enter SSL key path: " thiskeypath
echo "ROOT $wwwroot" > tmp/settings.txt
echo "SVR $servername" >> tmp/settings.txt
echo "CERT $thiscertpath" >> tmp/settings.txt
echo "KEY $thiskeypath" >> tmp/settings.txt
