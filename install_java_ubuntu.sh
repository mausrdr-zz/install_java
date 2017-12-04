#!/bin/bash
#
#################################################
#                 Elaborado por:                #
#         Mauro Augusto Soares Rodrigues        #
#                      v3.2                     #
#################################################
#
# Script para instalacao do java jre ou jdk
# Para executar utilize o seguinte comando: ./install_java_ubuntu_server.sh num_vresao num_descompactado plataforma
# Onde num_versao voce ira colocar o numero da versao corrente do java
# num_descompactado sera iniciado pelo numeral 1 seguido de um ponto ".", mais o primeiro numero da versao,
# seguido de outro ponto ".", o numeral zero, o caractere underline "_" e os dois ultimos numeros da
# versao. Ex.: se a versao for 7u67 o num_descompactado sera 1.7.0_67
# E plataforma indicara se sera instalado jre ou jdk
# Ex.: ./install_java_ubuntu_server.sh 7u67 1.7.0_67 jre

function init_reset_db_files() {
	if [[ -e /root/older_java_jre.db ]]; then
		rm -rfv /root/older_java_jre.db;
	fi
	if [[ -e /root/older_java_jdk.db ]]; then
		rm -rfv /root/older_java_jdk.db;
	fi
}

function init_reset_profile() {
	if [[ -e /etc/profile.original ]]; then
		cp -a /etc/profile.original /etc/profile;
	else
		cp -a /etc/profile /etc/profile.original;
	fi
}

function remove_previous() {
	amount_jre=$(ls /usr/java | grep jre | wc -l)
	amount_jdk=$(ls /usr/java | grep jdk | wc -l)
	if [[ $amount_jdk -ne 0 || $amount_jre -ne 0 ]]; then
		if [[ $amount_jdk -eq 0 ]]; then
			if [[ $amount_jre -eq 1 ]]; then
				older_java=$(ls /usr/java | grep jre | cut -d '' -f 1)
				update-alternatives --remove java /usr/java/$older_java/bin/java;
				update-alternatives --remove javaws /usr/java/$older_java/bin/javaws;
				rm -rfv /usr/java/$older_java;
			else
				older_java=$(ls /usr/java | grep jre | cut -d '' -f 1)
				echo $older_java > older_java_jre.db;
				while read entry_older_jre; do
					update-alternatives --remove java /usr/java/$entry_older_jre/bin/java;
					update-alternatives --remove javaws /usr/java/$entry_older_jre/bin/javaws;
					rm -rfv /usr/java/$entry_older_jre;
				done < /root/older_java_jre.db
			fi
		else
			if [[ $amount_jdk -eq 1 ]]; then
				older_java=$(ls /usr/java | grep jdk | cut -d '' -f 1)
				update-alternatives --remove java /usr/java/$older_java/jre/bin/java;
				update-alternatives --remove javaws /usr/java/$older_java/jre/bin/javaws;
				rm -rfv /usr/java/$older_java;
			else
				older_java=$(ls /usr/java | grep jdk | cut -d '' -f 1)
				echo $older_java > older_java_jdk.db;
				while read entry_older_jdk; do
					update-alternatives --remove java /usr/java/$entry_older_jdk/jre/bin/java;
					update-alternatives --remove javaws /usr/java/$entry_older_jdk/jre/bin/javaws;
					rm -rfv /usr/java/$entry_older_jdk;
				done < /root/older_java_jdk.db
			fi
		fi
	fi
}

function install_java() {
	case $1 in
		jre)
			if [[ $3 -eq 1 ]]; then
				remove_previous;
			fi
			mv $1$2 /usr/java;
			chown root:root -R /usr/java/$1$2;
			update-alternatives --install /usr/bin/java java /usr/java/$1$2/bin/java 10;
			update-alternatives --install /usr/bin/javaws javaws /usr/java/$1$2/bin/javaws 10;
			update-alternatives --set java /usr/java/$1$2/bin/java;
			update-alternatives --set javaws /usr/java/$1$2/bin/javaws;
			;;
		jdk)
			if [[ $3 -eq 1 ]]; then
				remove_previous;
			fi
			mv $1$2 /usr/java;
			chown root:root -R /usr/java/$1$2;
			update-alternatives --install /usr/bin/java java /usr/java/$1$2/jre/bin/java 10;
			update-alternatives --install /usr/bin/javaws javaws /usr/java/$1$2/jre/bin/javaws 10;
			update-alternatives --set java /usr/java/$1$2/jre/bin/java;
			update-alternatives --set javaws /usr/java/$1$2/jre/bin/javaws;
			;;
	esac
}

function set_env_variables() {	
	echo "" >> /etc/profile;
	echo "# Environment Variable of Oracle Java installed by" >> /etc/profile;
	echo "# script install_java_ubuntu_server.sh placed on" >> /etc/profile;
	echo "# /root directory." >> /etc/profile;
	echo "JAVA_HOME=/usr/java/$1$2" >> /etc/profile;
	if [[ $1 == jdk ]]; then
	  echo "JRE_HOME=/usr/java/$1$2/jre" >> /etc/profile;
	  echo "PATH=\$PATH:\$JAVA_HOME/bin:\$JRE_HOME/bin" >> /etc/profile;
	else
	  echo "JRE_HOME=/usr/java/$1$2/bin" >> /etc/profile;
	  echo "PATH=\$PATH:\$JAVA_HOME:\$JRE_HOME" >> /etc/profile;
	fi
	echo "export JAVA_HOME" >> /etc/profile;
	echo "export JRE_HOME" >> /etc/profile;
	echo "export PATH" >> /etc/profile;
}

init_reset_profile
init_reset_db_files

wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/$1-b11/d54c1d3a095b4ff2b6607d096fa80163/$3-$1-linux-x64.tar.gz;
tar -zxvf $3-$1-linux-x64.tar.gz;
rm -rfv $3-$1-linux-x64.tar.gz;


if [[ -d /usr/java ]]; then
	install_java $3 $2 1
else
  mkdir /usr/java;
  install_java $3 $2
fi

set_env_variables $3 $2
. /etc/profile;
clear;
java -version;
