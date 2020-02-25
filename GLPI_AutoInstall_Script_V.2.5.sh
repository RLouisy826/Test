#!/bin/bash

clear

MiseaJour(){
	cd /etc
	mkdir GLPI_logs
	echo -e "\033[33m ==> Mise à jour de l'OS\033[0m"
	majcentos="yum -y update"
    echo "Lancement de la commande: $majcentos"
    sleep 1
	eval $majcentos > /etc/GLPI_logs/log_MAJ.txt
	exit_status=$?
	if [ $exit_status -eq 0 ]; then
		echo -e "\033[32mOk toutes les MàJ ont été faites\033[0m\n"
	else
		echo -e "\033[31mIl reste des MàJ, fais les manuellement en saisissant la commande : $majcentos\033[0m\n"
		exit 1;
	fi
	sleep 1

	echo -e "\033[33m ==> Installation de wget\033[0m"
	wget="yum -y install wget"
    echo "Lancement de la commande: $wget"
    sleep 1
	eval $wget >> /etc/GLPI_logs/log_MAJ.txt
	test=$(command -v wget);
	if [ "$?" != "0" ]; then
		echo -e "\033[31mwget ne s'est pas installé correctement\033[0m\n"
		exit 2;
	fi;
	echo -e "\033[32mLa commande wget a été installée\033[0m\n"
	sleep 1

	echo -e "\033[33m ==> Ajout des repos requis\033[0m"
	repo1="wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
	repo2="wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm"
	echo "Lancement de la commande: $repo1"
	eval $repo1 >> /etc/GLPI_logs/log_MAJ.txt 2> /etc/GLPI_logs/logerreur.txt
	echo "Lancement de la commande: $repo2"
	eval $repo2 >> /etc/GLPI_logs/log_MAJ.txt 2> /etc/GLPI_logs/logerreur.txt
	echo -e "\033[32mLes répos ont été ajouté\033[0m\n"
	sleep 1

}

installationMariaDB(){
	echo -e "\033[33m ==> Installation MariaDB\033[0m"
	echo "[mariadb]" > /etc/yum.repos.d/MariaDB.repo
	echo "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo
	echo "baseurl = http://yum.mariadb.org/10.4/centos7-amd64" >> /etc/yum.repos.d/MariaDB.repo
	echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
	echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo

	installMaria="yum -y install mariadb-server mariadb-client"
		echo "Lancement de la commande: $installMaria"
		sleep 1
		eval $installMaria >> /etc/GLPI_logs/log_MariaDB.txt 2> /etc/GLPI_logs/logerreur.txt
		echo "Initialisation du service mariadb"
		sleep 1
	systemctlMaria1="systemctl start mariadb"
	eval $systemctlMaria1 >> /etc/GLPI_logs/log_MariaDB.txt 2> /etc/GLPI_logs/logerreur.txt
	systemctlMaria2="systemctl enable mariadb"
	eval $systemctlMaria2 >> /etc/GLPI_logs/log_MariaDB.txt 2> /etc/GLPI_logs/logerreur.txt
	systemctlMaria3="systemctl status mariadb"
	eval $systemctlMaria3 >> /etc/GLPI_logs/log_MariaDB.txt 2> /etc/GLPI_logs/logerreur.txt
	exit_status=$?
	if [ $exit_status -eq 0 ]; then
		echo -e "\033[32mMariaDB à bien été installé\033[0m\n"
	else
		echo -e "\033[31mL'installation n'a pas abouti\033[0m\n"
		exit 1;
	fi
	sleep 1
}

installationApache(){
	echo -e "\033[33m ==> Installation d'Apache\033[0m"
	installApache="yum -y install httpd"
		echo "Lancement de la commande: $installApache"
		sleep 1
	eval $installApache >> /etc/GLPI_logs/log_Apache.txt 2> /etc/GLPI_logs/logerreur.txt
	systemctlApache1="systemctl start httpd"
		eval $systemctlApache1 >> /etc/GLPI_logs/log_Apache.txt 2> /etc/GLPI_logs/logerreur.txt
	cd /tmp
	wget https://github.com/RLouisy826/Test/blob/master/httpd.conf
	rm -f /etc/httpd/conf/httpd.conf
	mv /tmp/httpd.conf /etc/httpd/conf
	eval $systemctlApache1 >> /etc/GLPI_logs/log_Apache.txt 2> /etc/GLPI_logs/logerreur.txt
	echo "Initialisation du service httpd"
	sleep 1
	systemctlApache2="systemctl enable httpd"
	eval $systemctlApache2 >> /etc/GLPI_logs/log_Apache.txt 2> /etc/GLPI_logs/logerreur.txt
	firewall-cmd --zone=public --add-port=http/tcp --permanent
	firewall-cmd --zone=public --add-port=https/tcp --permanent
	firewall-cmd --reload
	exit_status=$?
	if [ $exit_status -eq 0 ]; then
		echo -e "\033[32mLe pare-feu a été configuré\033[0m\n"
	else
		echo -e "\033[31mLe pare-feu n'est pas configurer\033[0m\n"
		exit 1;
	fi
	sleep 1
}

installationPHP(){
	echo -e "\033[33m ==> Installation PHP\033[0m"
	php1="yum -y install yum-utils epel-release"
	echo "Lancement de la commande: $php1"
	sleep 1
	eval $php1 >> /etc/GLPI_logs/log_PHP.txt 2> /etc/GLPI_logs/logerreur.txt

	php2="yum-config-manager --enable remi-php72"
	echo "Lancement de la commande: $php2"
	sleep 1
	eval $php2 >> /etc/GLPI_logs/log_PHP.txt 2> /etc/GLPI_logs/logerreur.txt

	php3="yum -y install php"
	echo "Lancement de la commande: $php3"
	sleep 1
	eval $php3 >> /etc/GLPI_logs/log_PHP.txt 2> /etc/GLPI_logs/logerreur.txt

	echo -e "\033[33m ==> Installation des extensions PHP\033[0m"
	php4="yum -y install php-opcache php-apcu php-curl php-fileinfo php-gd php-json php-mbstring php-mysqli php-session php-zlib php-simplexml php-xml php-cli php-domxml php-imap php-ldap php-openssl php-xmlrpc"
	echo "Lancement de la commande: $php4"
	sleep 1
	eval $php4 >> /etc/GLPI_logs/log_PHP.txt 2> /etc/GLPI_logs/logerreur.txt
	echo "Redemarrage du service httpd"
	sleep 1
	systemctl restart httpd
	exit_status=$?
	if [ $exit_status -eq 0 ]; then
		echo -e "\033[32mPHP a été installé\033[0m\n"
	else
		echo -e "\033[31mPHP n'est pas installé\033[0m\n"
		exit 1;
	fi
	sleep 1
}

InstallationGLPI(){
	echo -e "\033[33m ==> Installation de GLPI\033[0m"
	installGLPI="wget https://github.com/glpi-project/glpi/releases/download/9.4.5/glpi-9.4.5.tgz"
	echo "Lancement de la commande: $installGLPI"
	sleep 1
	eval $installGLPI >> /etc/GLPI_logs/log_GLPI.txt 2> /etc/GLPI_logs/logerreur.txt
	echo -e "\033[33m ==> Decompression de GLPI\033[0m\n"
	glpi1="tar -xvzf glpi-9.4.5.tgz"
	echo "Lancement de la commande: $glpi1"
	sleep 1
	eval $glpi1 >> /etc/GLPI_logs/log_GLPI.txt 2> /etc/GLPI_logs/logerreur.txt
	mv glpi /var/www/html/
	exit_status=$?
	if [ $exit_status -eq 0 ]; then
		echo -e "\033[32mGLPI à été installé\033[0m\n"
	else
		echo -e "\033[31mGLPI n'est pas installer\033[0m\n"
		exit 1;
	fi
	sleep 1
}

DB_creation(){
	echo -e "\033[33m ==> Création de la Base de données GLPI\033[0m"
	mysql -u root -prootroot -e "CREATE DATABASE glpi;"
	mysql -u root -prootroot -e	"CREATE USER 'glpi'@'localhost' IDENTIFIED BY 'glpipass';"
	mysql -u root -prootroot -e	"GRANT ALL PRIVILEGES ON glpi.* TO 'glpi'@'localhost';"
	mysql -u root -prootroot -e	"FLUSH PRIVILEGES;"
	exit_status=$?
	if [ $exit_status -eq 0 ]; then
		echo -e "\033[32mLa base de données a été creé\033[0m\n"
	else
		echo -e "\033[31mLa base de données n'a pas été creé\033[0m\n"
		exit 1;
	fi
	sleep 1
}

Setsebool_on(){
	echo -e "\033[33m ==> Activation des variables Bool\033[0m"
	setsebool -P httpd_can_network_connect on
	getbool1="getsebool httpd_can_network_connect"
	eval $getbool1 >> /etc/GLPI_logs/log_SEbool.txt 2> /etc/GLPI_logs/logerreur.txt
	setsebool -P httpd_can_network_connect_db on
	getsebool2="getsebool httpd_can_network_connect_db"
	eval $getsebool2 >> /etc/GLPI_logs/log_SEbool.txt 2> /etc/GLPI_logs/logerreur.txt
	setsebool -P httpd_can_sendmail on
	getsebool3="getsebool httpd_can_sendmail"
	eval $getsebool3 >> /etc/GLPI_logs/log_SEbool.txt 2> /etc/GLPI_logs/logerreur.txt
	sleep 1
}

Rights_glpi(){
	chown -R apache:apache /var/www/html/glpi
	chmod -R 777 /var/www/html/glpi
}

credentials(){
	echo "Inforamtion de connexion à la base de données">> /etc/DB_Info.txt
	echo "ID : glpi">> /etc/DB_Info.txt
	echo "MDP : glpipass">> /etc/DB_Info.txt
	echo "BDD : glpi">> /etc/DB_Info.txt
}

echo -e "\tProgramme d'installation de GLPI 9.4.5 \n"
MiseaJour
installationMariaDB
installationApache
installationPHP
InstallationGLPI
DB_creation
Setsebool_on
Rights_glpi
credentials
echo -e "\tGLPI a bien été installé\n"
echo -e "\tAccéder à votre glpi en utilisant un navigateur web \n"
echo -e "\t \n"
echo -e "\tLes identifiants de la Base de données se trouve ici : \n"
echo -e "\t/etc/DB_Info.txt\n"
echo -e "\t \n"
