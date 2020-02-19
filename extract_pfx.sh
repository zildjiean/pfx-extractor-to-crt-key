#!/bin/bash
#########################################################################################
#
# Original by https://gist.github.com/mediaupstream/a2694859b1afa59f26be5e8f6fd4806a
# Thank you mediaupstream on github
#
# Modify by Piyapong 07-Nov-2019
# Usage: sh <this_script.sh> PFXcert without extension .pfx
# Adding: Checking Missing, Verify .crt and .key,Result Color and Clean-up after process
#
##########################################################################################

filename=$1

if [ -z $filename ];
then 
	echo "\e[31m\e[1mNo Operation"
	echo "\e[39m\e[0mPlese enter PFX name (without extension .pfx)"
	echo "\e[39m\e[0mExample: extract_cert.sh example.com"
else

# Read PFX Password
read -p "Please enter password: " pfxpass

# Clear terminal
clear

# extract ca-certs
echo "\e[31m> \e[32mExtracting ca-certs..."
/usr/bin/openssl pkcs12 -in ${filename}.pfx -nodes -nokeys -cacerts -out ${filename}-ca.crt -passin pass:$pfxpass
echo "\e[32mdone!"
echo " "

# extract key
echo "\e[31m> \e[32mExtracting key file..."
/usr/bin/openssl pkcs12 -in ${filename}.pfx -nocerts -out ${filename}.key -passin pass:$pfxpass -passout pass:$pfxpass
echo "\e[32mdone!"
echo " "

# extract crt
echo "\e[31m> \e[32mExtracting crt..."
/usr/bin/openssl pkcs12 -in ${filename}.pfx -clcerts -nokeys -out ${filename}.crt -passin pass:$pfxpass

# extract crt for check md5 and program will delete in last process
/usr/bin/openssl pkcs12 -in ${filename}.pfx -clcerts -nokeys -out ${filename}-noCA.crt -passin pass:$pfxpass

echo "\e[31m> \e[32mCombining ca-certs with crt file..."
# combine ca-certs and cert files
cat ${filename}-ca.crt ${filename}.crt > ${filename}-full.crt

# remove passphrase from key file
echo "\e[39m> Removing passphrase from keyfile"

/usr/bin/openssl rsa -in ${filename}.key -out ${filename}.key -passin pass:$pfxpass

# clean up
rm ${filename}-ca.crt
mv ${filename}-full.crt ${filename}.crt

echo "\e[32mdone!"
echo " "
echo "\e[32mExtraction complete! 🐼"
echo "\e[32mcreated files:"
echo " 🔑  ${filename}.key"
echo " 📄  ${filename}.crt"
echo " "


#check crt and key is matching
crtmd5=$(/usr/bin/openssl x509 -noout -modulus -in ${filename}-noCA.crt | openssl md5 | cut -c10-)
keymd5=$(/usr/bin/openssl rsa -noout -modulus -in ${filename}.key | openssl md5 | cut -c10-)
sleep 1
echo "\e[31m> \e[32mCalculate hashing .crt"
sleep 1
echo "\e[39m${crtmd5}"

sleep 1
echo "\e[31m> \e[32mCalculate hashing .key"
sleep 1
echo "\e[39m${keymd5}"
echo " "

# Check md5 cert is matching?
if [ $crtmd5 = $keymd5 ];
then
	echo "\e[32m\e[1mCert and Key Matching!!!"
	echo "\e[32m\e[1mDone !"
else
	echo "\e[31m\e[1mCert and Key not Match!!!"
	echo "\e[31m\e[1mPlease check PFX file."
fi

echo " "
echo "\e[39m> Clean up..."
# All Clean
rm ${filename}-noCA.crt
echo " "
fi
