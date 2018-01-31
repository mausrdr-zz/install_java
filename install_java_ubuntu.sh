#!/bin/bash
#
#################################################
#                 Elaborado por:                #
#         Mauro Augusto Soares Rodrigues        #
#                      v4.0                     #
#################################################
#
# Script para instalacao do java jre ou jdk
# Para executar utilize o seguinte comando: ./install_java_ubuntu_server.sh num_vresao plataforma
# num_versao e a versao corrente do java.
# E plataforma indicara se sera instalado jre ou jdk
# Ex.: ./install_java_ubuntu_server.sh 9.0.4 jre

function init_reset_db_files() {
	if [[ -e /root/older_java_jre.db ]]; then
		rm -rfv /root/older_java_jre.db;
	fi
	if [[ -e /root/older_java_jdk.db ]]; then
		rm -rfv /root/older_java_jdk.db;
	fi
}

function init_reset_javalink_files() {
	if [[ -e /root/javalink ]]; then
		rm -rfv /root/javalink;
	fi
	if [[ -e /root/javalinkdown ]]; then
		rm -rfv /root/javalinkdown;
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
				older_java=$(ls /usr/java | grep jre | cut -d '' -f1)
				update-alternatives --remove java /usr/java/$older_java/bin/java;
				update-alternatives --remove javaws /usr/java/$older_java/bin/javaws;
				rm -rfv /usr/java/$older_java;
			else
				older_java=$(ls /usr/java | grep jre | cut -d '' -f1)
				echo $older_java > older_java_jre.db;
				while read entry_older_jre; do
					update-alternatives --remove java /usr/java/$entry_older_jre/bin/java;
					update-alternatives --remove javaws /usr/java/$entry_older_jre/bin/javaws;
					rm -rfv /usr/java/$entry_older_jre;
				done < /root/older_java_jre.db
			fi
		else
			if [[ $amount_jdk -eq 1 ]]; then
				older_java=$(ls /usr/java | grep jdk | cut -d '' -f1)
				update-alternatives --remove java /usr/java/$older_java/jre/bin/java;
				update-alternatives --remove javaws /usr/java/$older_java/jre/bin/javaws;
				rm -rfv /usr/java/$older_java;
			else
				older_java=$(ls /usr/java | grep jdk | cut -d '' -f1)
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

function get_package() {
	curl -fLC - --retry 3 --retry-delay 3 -b oraclelicense=a -o javalink http://www.oracle.com/technetwork/java/javase/downloads/index.html
	if [[ $1 == jdk ]]; then
		jdk_str="jdk9-downloads"
		for (( i = 1; i < 1000; i++ )); do
			link_url=`grep  ">JRE" javalink | tr -s " " | tr -d \" | sed '/>JRE/!d' | cut -d= -f$i | cut -d" " -f1`
			if [[ ${link_url,,} =~ $jdk_str ]]; then
				curl -fLC - --retry 3 --retry-delay 3 -b oraclelicense=a -o javalinkdown $link_url
				down_url=`grep "\['$1-$2_linux-x64_bin.tar.gz'\]" javalinkdown | tr -d \" | cut -d: -f4,5 | cut -d, -f1`
				wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $down_url
				break
			fi
		done
	else
		jre_str="jre9-downloads"
		for (( i = 0; i < 10; i++ )); do
			#statements
			link_url=`grep  ">JRE" javalink | tr -s " " | tr -d \" | sed '/>JRE/!d' | cut -d= -f$i | cut -d" " -f1`
			if [[ ${link_url,,} =~ $jre_str ]]; then
				#statements
				curl -fLC - --retry 3 --retry-delay 3 -b oraclelicense=a -o javalinkdown $link_url
				down_url=`grep "\['$1-$2_linux-x64_bin.tar.gz'\]" javalinkdown | tr -d \" | cut -d: -f4,5 | cut -d, -f1`
				wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $down_url
				break
			fi
		done
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
init_reset_javalink_files

get_package $2 $1
tar -zxvf $2-$1_linux-x64_bin.tar.gz;
rm -rfv $2-$1_linux-x64_bin.tar.gz;


if [[ -d /usr/java ]]; then
	install_java $2 $1 1
else
  mkdir /usr/java;
  install_java $2 $1
fi

set_env_variables $2 $1
. /etc/profile;
clear;
java -version;
