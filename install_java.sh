#!/bin/bash
#
#################################################
#		            Elaborado por:                  #
#	      Mauro Augusto Soares Rodrigues		      #
#		                  v3.0                			#
#################################################
#
# Script para instalacao do java jre ou jdk
# Para executar utilize o seguinte comando: ./install_java.sh num_vresao num_descompactado plataforma
# Onde num_versao voce ira colocar o numero da versao corrente do java
# num_descompactado sera iniciado pelo numeral 1 seguido de um ponto ".", mais o primeiro numero da versao, seguido de outro ponto ".", o numeral zero, o caractere underline "_" e os dois ultimos numeros da  
# versao. Ex.: se a versao for 7u67 o num_descompactado sera 1.7.0_67
# E plataforma indicara se sera instalado jre ou jdk
# Ex.: ./install_java.sh 7u67 1.7.0_67 jdk

wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/$1-b17/$3-$1-linux-x64.rpm;
sudo rpm -Uvh $3-$1-linux-x64.rpm;

sudo update-alternatives --install /usr/bin/java java /usr/java/$3$2/bin/java 10;
sudo update-alternatives --install /usr/bin/javac javac /usr/java/$3$2/bin/javac 10;
sudo update-alternatives --install /usr/bin/javaws javaws /usr/java/$3$2/bin/javaws 10;
sudo update-alternatives --set java /usr/java/$3$2/bin/java;
sudo update-alternatives --set javac /usr/java/$3$2/bin/javac;
sudo update-alternatives --set javaws /usr/java/$3$2/bin/javaws;
java -version;

if ls /usr/lib64/mozilla/plugins | grep libjavaplugin.so
then
  sudo rm -rfv /usr/lib64/mozilla/plugins/libjavaplugin.so;
  sudo ln -sf /usr/java/$3$2/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/libjavaplugin.so;
  echo Plugin do Firefox instalado.
fi
