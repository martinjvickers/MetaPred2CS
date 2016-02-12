# MetaPred2CS

Webserver implementation of MetaPred2CS, a sequence-based meta-predictor for protein-protein interactions of prokaryotic two-component system proteins written by Altan Kara and maintained by Martin Vickers. 

A live version of this is running here;

http://metapred2cs.ibers.aber.ac.uk

A. Kara, M. Vickers, M. Swain, D.E. Whitworth and N. Fernandez-Fuentes. Genome-wide prediction of prokaryotic two-component system networks using a sequence-based meta-predictor. BMC Bioinformatics 2015, 16:297. http://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-015-0741-7

##Install Instructions

###Using Ubuntu server 14.03 LTS
  ```
  sudo apt-get update
  sudo apt-get upgrade
  ```

###Install dependencies

  ```
  apt-get install git apache2 make clustalw blast2 libapache2-mod-fastcgi libapache2-mod-perl2 libapache2-mod-php5 php5 ncbi-blast+ perl libgd-gd2-perl libcgi-session-perl libclass-base-perl libexpat1-dev blast2 ncbi-blast+-legacy gcc libc6-dev bioperl
  ```
###git clone and put in correct places

  This will probably take quite a while as the repository is almost 1GB in size.

  ```
  git clone https://github.com/martinjvickers/MetaPred2CS.git
  cd MetaPred2CS
  cp -r MetaPred2cs /usr/lib/cgi-bin/MetaPred2cs/
  cp -r webserver_okul /var/www/
  cp -r html /var/www/
  chown -R www-data /var/www/html
  chown -R www-data /var/www/MetaPred2cs
  ```

###Copy sites-enabled script

   ```
   rm /etc/apache2/sites-enabled/000-default
   mv metapred2cs.conf /etc/apache2/sites-enabled/
   ```

###INSTALL CGI::Response.pm!

  ```
  wget ftp://ftp.auckland.ac.nz/pub/perl/CPAN/authors/Marc_Hedlund/CGI-Response-0.03.tar.gz
  tar xvf CGI-Response-0.03.tar.gz
  cd CGI-Response-0.03
  perl Makefile.PL
  make
  sudo make install
  ```

###Enable CGI module

  ```
  sudo a2enmod cgi
  sudo service apache2 restart
  ```

###Needed for virtual box

  `apt-get install virtualbox-guest-dkms`

###Install sqldatabase

  `apt-get install mysql-server`

###Create-Database

  ```
  mysql -u root -p
  create database Precalculated_inputs;
  grant usage on *.* to meta_user@localhost identified by 'supersecret';
  grant all privileges on Precalculated_inputs.* to meta_user@localhost;
  flush privileges;
  quit
  ```

###Import database

  `mysql -u meta_user -p Precalculated_inputs < mysql_updated.sql`

###Uniprot DB?
