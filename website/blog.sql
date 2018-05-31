-- MySQL dump 10.16  Distrib 10.1.33-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: blog
-- ------------------------------------------------------
-- Server version	10.1.33-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `Articles`
--

DROP TABLE IF EXISTS `Articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'title',
  `date` date DEFAULT NULL,
  `category` varchar(52) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'category',
  `content` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `thumbnail` varchar(45) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'dual-parallax.jpg',
  `tags` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'tag1,tag2',
  `wip` varchar(3) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'yes',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Articles`
--

LOCK TABLES `Articles` WRITE;
/*!40000 ALTER TABLE `Articles` DISABLE KEYS */;
INSERT INTO `Articles` VALUES (1,'lamp_stack_on_centos','Setting up a LAMP Stack on CentOS 7','2018-02-22','development','<p>Welcome to the first post of my blog! This article will teach you how to set up a LAMP <code>Linux(CentOS), Apache, MySQL, Python</code> web server from scratch, just like how I did to get this blog running. This guide will go through everything and not all of it may apply to your circumstance, so feel free to skip ahead using the table of contents.</p>\n<h4>Table of Contents</h4>\n<ul>\n    <li><a href=\"#0x100\">The DNS and Web Server</a></li>\n    <li><a href=\"#0x200\">Initial Server Setup</a></li>\n    <li><a href=\"#0x300\">AMP\'ed up</a></li>\n    <li><a href=\"#0x400\">The Apache Config</a></li>\n</ul>\n\n<h3 id=\"0x100\">0x100: the DNS and web server</h3><hr>\n<p>The DNS (Domain Name System) is a system that resolves a server\'s domain name eg. <code>blog.justinduch.com</code> into an IP address. In order for your webpage to be viewable, you must point your domain name to the webserver.</p>\n<p>As this process is different for every domain name registrar and server provider it is up to you to find the documentation to do this for your specific setup. Once you have a sever and domain name aswell as pointed them, we can continue with the guide.</p>\n\n<h3 id=\"0x200\">0x200: initial server setup</h3><hr>\n<p>Once you have your new server, you can log into it through SSH with it\'s public IP address. On Linux/Mac machines, use the command:</p>\n<pre>[user@okcomputer]$ ssh root@SERVER_IP</pre>\n<p>or connect through PUTTY on a Windows machine.</p>\n\n<h4>0x201: adding a new user</h4>\n<p>Now you are logged in as the <code>root</code> user, which is the administrative user in a Linux environment and is given heightend privilages. Because of this, we will create a new user that we will use to log in from now in order to help prevent making any destructive changes on accident.</p>\n<pre>[root@okserver]# useradd USER_NAME</pre>\n<p>Now you can assign the user a password:</p>\n<pre>[root@okserver]# passwd USER_NAME</pre>\n<p>Our new user has been set up, but it only has regular user privilages. If we ever want to do administrative tasks on the server (like installing packages in the later sections), our regular user will be denied access. To avoid having to go back to root, we can set up our user as a \'super user\'. This allows the user to run commands with root privilages by adding <code>sudo</code> before each command.</p>\n<p>To do this we will add our user to the <code>wheel</code> group. By default, on CentOS, members of the <code>wheel</code> group have sudo privileges.</p>\n<pre>[root@okserver]# usermod -aG wheel USER_NAME</pre>\n\n<h4>0x202: configuring ssh</h4>\n<p>To make our server more secure we will configure the SSH daemon to disallow remote SSH access from root and change the deafult SSH port. Changing the default port from 22 to someting more unique will help to stop many automated attacks, and make it harder to guess which port SSH is accessible from. You can enter any port number from 1024 to 32,767.</p>\n<p>Open the configuration file on your text editor eg. vi or nano:</p>\n<pre>[root@okserver]# vi /etc/ssh/sshd_config</pre>\n<p>Look for the lines:</p>\n<pre>...&#13;&#10;Port 22&#13;&#10;...&#13;&#10;#PermitRootLogin yes</pre>\n<p>and change them to:</p>\n<pre>...&#13;&#10;Port YOUR_PORT_NUMBER&#13;&#10;...&#13;&#10;PermitRootLogin no</pre>\n<p>Now that we have made our changes, we will restart SSH and test our configuration:</p>\n<pre>[root@okserver]# systemctl reload ssh</pre>\n<p>Open a <b>new</b> terminal window (do not disconnect from the old session until we can verify that the config works) and connect with the command:</p>\n<pre>[user@okcomputer]$ ssh -p PORT user@SERVER_IP</pre>\n<p>You should now be logged in as your new user through the new SSH port. If your server has a firewall you may also want to allow TCP connections through the new port and block the old port.</p>\n\n<h3 id=\"0x300\">0x300: AMP\'ed up</h3><hr>\n<p>With our server configured we can now go through the the final 3 letters of the LAMP stack.</p>\n<p>Before we install anything we should update the system:</p>\n<pre>[user@okserver]$ sudo yum -y update</pre>\n<p>Remember that we need to use <code>sudo</code> from now on to gain root privilages!</p>\n<p>From now on this guide will use vim instead of vi as it\'s text editor, to install vim enter:</p>\n<pre>[user@okserver]$ sudo yum install vim</pre>\n\n<h4>0x301: a for apache</h4>\n<p>Install Apache with:</p>\n<pre>[user@okserver]$ sudo yum install httpd</pre>\n<p>now you can start and enable the service:</p>\n<pre>[user@okserver]$ sudo systemctl start httpd.service&#13;&#10;[user@okserver]$ sudo systemctl enable httpd.service</pre>\n\n<h4>0x302: m for mysql</h4>\n<p>We are actually installing MariaDB for our database, but it still starts with a \'m\' so it counts.</p>\n<pre>[user@okserver]$ sudo yum install mariadb mariadb-server</pre>\n<p>start and enable it:</p>\n<pre>[user@okserver]$ sudo systemctl start mariadb&#13;&#10;[user@okserver]$ sudo systemctl enable mariadb</pre>\n<p>Now you will want to set up the database. Add a root user with:</p>\n<pre>[user@okserver]$ mysqladmin -u root password PASSWORD</pre>\n<p>You can test it by connecting to the database with:</p>\n<pre>[user@okserver]$ mysql -u root -p</pre>\n\n<h4>0x303: p for python</h4>\n<p>CentOS actually comes with Python2.7 by deafult, so if you are one of those neanderthals who still use 2.7 you can skip this step. For the rest of us intellectuals, you will need to install install IUS, which stands for Inline with Upstream Stable. IUS provides the Red Hat Package Manager (RPM) packages for some newer versions of select software.</p>\n<pre>[user@okserver]$ sudo yum install https://centos7.iuscommunity.org/ius-release.rpm</pre>\n<p>Now you can install Python3:</p>\n<pre>[user@okserver]$ sudo yum install python36u</pre>\n<p>You may also want to install pip and the development package needed for the mysqldb module:</p>\n<pre>[user@okserver]$ sudo yum install python36u-pip python36u-devel</pre>\n\n<p>Now your LAMP stack is installed! The next section goes through the Apache config to get you to the testing page.</p>\n\n<h3 id=\"0x400\">0x400: the apache config</h3><hr>\n<p>This section will go through how to get a set up a virtual host in Apache. You can choose many different ways to set up a virtual host, this guide will show the way I did it.</p>\n<p>Create the required directories for the website:</p>\n<pre>[user@okserver]$ sudo mkdir /var/www/YOUR_DOMAIN&#13;&#10;[user@okserver]$ sudo mkdir /var/www/YOUR_DOMAIN</span>/cgi-bin&#13;&#10;[user@okserver]$ sudo mkdir /var/www/YOUR_DOMAIN/html&#13;&#10;[user@okserver]$ sudo mkdir /var/www/YOUR_DOMAIN/conf</pre>\n<p><code>cgi-bin</code> is the directory where you will keep your scripts.</p>\n<p><code>html</code> is the document root for Apache.</p>\n<p><code>conf</code> is the directory where your virtual host config is placed.</p>\n<p>Now create <code>vhost.conf</code> in the <code>conf</code> directory:</p>\n<pre>[user@okserver]$ sudo touch /var/www/YOUR_DOMAIN/conf/vhost.conf</pre>\n<p>and and edit it: <pre>[user@okserver]$ sudo vim /var/www/example.com/conf/vhost.conf</pre> Here is a very basic example where <code>example.com</code> is my domain name:</p>\n<pre>\n&ltVirtualHost *:80&gt\n    ServerAdmin admin@example.com\n    ServerName example.com\n    ServerAlias /app/ \"/var/www/example.com/cgi-bin/\"\n    DocumentRoot /var/www/example.com/html\n&lt/VirtualHost&gt\n</pre>\n<p>Now we can edit the Apache config to include this virtual host config:</p>\n<pre>[user@okserver]$ sudo vim /etc/httpd/conf/httpd.conf</pre>\n<p>and add this line to the end of the file:</p>\n<pre>Include /var/www/example.com/conf/vhost.conf</pre>\n<p>Restart Apache with:</p>\n<pre>[user@okserver]$ sudo apachectl graceful</pre>\n<p>That\'s it! You can test if your web server works by typing your domain into the browser, which should direct you to Apache\'s testing page. For more config options see the <a href=\"https://httpd.apache.org/docs/2.4/vhosts/\" target=\"_blank\">official documentation</a>.</p>','dual-parallax.jpg','linux,centos,apache,mysql,python','no'),(2,'ssl_and_encryption','SSL and Encryption','2018-04-02','development','<p>TLS (Transfer Layer Security) / SSL (Secure Socket Layer) are standard, cryptographic protocols that establish security over computer networks, between a web server and a browser. SSL provides a trusted environment where all data being transmitted is encrypted.</p>\n                <p>This article is technically a continuation of my <a href=\"/article/lamp_stack_on_centos\" target=\"_blank\">last article</a> where we set up a CentOs7 server with Apache, and will go through explaining SSL aswell as setting it up our sever.</p>\n                <h4>table of contents</h4>\n                <ul>\n                    <li><a href=\"#0x100\">TLS/SSL?</a></li>\n                    <li><a href=\"#0x200\">A Primer on Encryption and SSL</a></li>\n                    <li><a href=\"#0x300\">The SSL Certificate</a></li>\n                    <li><a href=\"#0x400\">Let\'s Encrypt</a></li>\n                </ul>\n\n                <h3 id=\"0x100\">0x100: TLS/SSL?</h3><hr>\n                <p>The terms SSL and TLS are often used interchangeably or in conjunction with each other (TLS/SSL), but one is in fact the predecessor of the other — SSL 3.0 served as the basis for TLS 1.0 which, as a result, is sometimes referred to as SSL 3.1.</p>\n                <p>As SSL was named by Netscape, the creators of the protocol, it was changed to TLS to avoid any legal issues with them so that the protocol could be \"open and free\". It also hints at the idea that the protocol works over any bidirectional stream of bytes, not just Internet-based sockets.</p>\n                <p>In order to prevent any confusion we will refer to TLS/SSL as just SSL from now on.</p>\n\n                <h3 id=\"0x200\">0x200: a primer on encryption and SSL</h3><hr>\n                <h4>0x201: asymertric and symmetric encryption</h4>\n                <p>Asymmetric encryption (or public-key cryptography) uses a separate key for encryption and decryption. Anyone can use the encryption key (public key) to encrypt a message. However, decryption keys (private keys) are secret. This way only the intended receiver can decrypt the message.</p>\n                <p>Asymmetric keys are typically 1024 or 2048 bits. However, keys smaller than 2048 bits are no longer considered safe to use. Though larger keys can be created, the increased computational burden is so significant that keys larger than 2048 bits are rarely used. To put it into perspective, it would take an average computer more than 14 billion years to crack a 2048-bit certificate.</p>\n                <p>Symmetric encryption (or pre-shared key encryption) uses a single key to both encrypt and decrypt data. Both the sender and the receiver need the same key to communicate.</p>\n                <p>Symmetric key sizes are typically 128 or 256 bits, where a larger key is harder to crack. For example, a 128-bit key has <code>340,282,366,920,938,463,463,374,607,431,768,211,456</code> encryption code possibilities.</p>\n                <p>Whether a 128-bit or 256-bit key is used depends on the encryption capabilities of both the server and the client software. SSL Certificates do not dictate what key size is used. </p>\n\n                <h4>0x202: SSL</h4>\n                <p>An SSL encrypted connection is generated through both asymmetric and symmetric cryptography through an SSL handshake. In SSL communications, the server’s SSL Certificate contains an asymmetric public and private key pair. The session key that the server and the browser create during the SSL Handshake is symmetric. In essence:</p>\n                <ul>\n                    <li>The handshake begins when a client connects to an SSL-enabled server requesting a secure connection.</li>\n                    <li>The server then provides identification in the form of a digital certificate. The certificate contains the server name, the trusted certificate authority (CA) that vouches for the authenticity of the certificate, and the server\'s public encryption key.</li>\n                    <li>The client confirms the validity of the certificate before proceeding and then creates a symmetric session key and encrypts it with the server\'s asymmetric public key. Then sends it to the server.</li>\n                </ul>\n                <p>This concludes the handshake and begins the secured connection, which is encrypted and decrypted with the session key until the connection closes. If any one of the above steps fails, then the SSL handshake fails and the connection is not created.</p>\n\n                <h3 id=\"0x300\">0x300: the SSL certificate</h3><hr>\n                <p>The SSL certificate is the most important component when generating an SSL connection between the client and server. Anyone can create a certificate, but browsers only trust certificates that come from an organization on their list of trusted CAs. Browsers come with a pre-installed list of trusted CAs, known as the Trusted Root CA store. In order to be added to the Trusted Root CA store and thus become a Certificate Authority, a company must comply with and be audited against security and authentication standards established by the browsers.</p>\n                <p>SSL Certificates will contain details of whom the certificate has been issued to. This includes the domain name or common name, serial number; the details of the issuer; the period of validity - issue date and expiry date; SHA Fingerprints; subject public key algorithm, subject\'s public key; certificate signature algorithm, certificate signature value. Other important details such as the type of certificate, SSL/TLS version, Perfect Forward Secrecy status, and cipher suite details are included. Organization validated and extended validation certificates also contain verified identity information about the owner of the website, including organization name, address, city, state and country.</p>\n                <p>For our server we will get an SSL certificate from Let\'s Encrypt, a free, automated, and open CA, run for the public’s benefit.</p>\n\n                <h3 id=\"0x400\">0x0400: let\'s encrypt</h3><hr>\n                <p>The first step to using Let\'s Encrypt to obtain an SSL certificate is to install the <code>certbot</code> software on our server. But before we begin, we must will need to enable the EPEL repository, which provides additional packages for CentOS, including the <code>certbot</code> package we need. We will also need to install the <code>mod_ssl</code> module to correctly serve encrypted traffic.</p>\n                <pre>[user@okserver]$ sudo yum install epel-release&#13;&#10;[user@okserver]$ sudo yum install mod_ssl python-certbot-apache</pre>\n\n                <h4>0x202: requesting a certificate</h4>\n                <p>Using <code>certbot</code> to generate a certificate is quite easy. The client will automatically obtain and install a new SSL certificate that is valid for the domains provided as parameters. To execute the interactive installation and obtain the certificates, run the certbot command with:</p>\n                <pre>[user@okserver]$ sudo certbot --apache -d YOUR_DOMAIN -d OPTIONAL_DOMAIN</pre>\n                <p>We will be presented with a step-by-step guide to customize our certificate options. We will be asked to provide an email address for lost key recovery and notices. If our Virtual Host files do not specify the domain they serve explicitly using the <code>ServerName</code> directive, we will be asked to choose the Virtual Host file (the default ssl.conf file should work).</p>\n                <p>That\'s pretty much it. The generated certificate files should be available within a subdirectory named after your base domain in the <code>/etc/letsencrypt/live</code> directory. However, as the default SSL configuration shipped with CentOS\'s version of Apache is a bit dated and as such, it is vulnerable to some more recent security issues and is recommended that we select more secure SSL options. I suggest going through Remy van Elst\'s <a href=\"https://raymii.org/s/tutorials/Strong_SSL_Security_On_Apache2.html\" target=\"blank\">tutorial</a> on strong SSL security on the Apache2 webserver, as it does a better job of explaining it\'s solutions than I would.</p>','dual-parallax.jpg','ssl,tls,encryption,centos,apache','no'),(3,'how_do_you_write_a_blog','How the Fuck Do You Write a Blog?','2018-05-30','development','<p>So far this blog has averaged 0.6 articles per month (including this one) since it was launched in Feburary. Normally you would assume this is just because I\'m lazy or that my social anxiety prevents me from writing anything on the internet because of a constant fear of judgement. And normally you\'d be right, and you are. But it\'s also because of something else.</p>\r\n<p>When I was first creating this blog, I wanted to make everything from scratch (the idiom, not the language) and I really do mean EVERYTHING. Flask? Literally any web framework? Why would I need that when I have Jinja and CGI? URL endpoints? HAH! I could just use the Apache config to map everything! Bootstrap?? WHAT A JOKE! I DON\'T NEED THAT! I\'M A CSS MASTER!</p>\r\n<p>Obviously this was a terrible idea that came from my original plans to have the entire website emulate the command line (which is also a terrible idea that I also have no idea how to do). So now four months later, we will look at the old site and laugh at how stupid I was.</p>\r\n<p>Right before I wrote this article, I mapped the old site on the Wayback Machine so you could go and <a target=\"_blank\" href=\"https://web.archive.org/web/20180529040508/https://blog.justinduch.com\">look at all 8 pages here.</a> You can also see the source code up to the final commit before this redesign <a target=\"_blank\" href=\"https://github.com/apt-helion/blog/tree/484e9c3d808e08ab41605a3c8a36c4793ba49274\">here.</a> I\'ve included some pictures in case you were to lazy to click on those.</p>\r\n<h4>table of contents</h4>\r\n<ul>\r\n    <li><a href=\"#0x100\">The Looks</a></li>\r\n    <li><a href=\"#0x200\">The Logic</a></li>\r\n    <li><a href=\"#0x300\">The Redesign</a></li>\r\n    <li><a href=\"#0x400\">What\'s Next</a></li>\r\n</ul>\r\n\r\n<h3 id=\"0x100\">0x100: The Looks</h3><hr>\r\n<p>There isn\'t too much to say here apart from: \'it isn\'t very nice\'. It was my first time using CSS grid in any real capacity, and while I do like it - probably more than Bootstrap, I wasn\'t able to do very much with my more limited CSS knowledge. You can see I had my original plans in mind while desiging it, with all it\'s plain-ness, but not a good minimalist plain, the bad, uninteresting plain.</p>\r\n<img class=\"img-responsive\" src=\"/common/static/img/blog1.0-root.png\" alt=\"image-alternative\"><sub>Figure 0: The homescreen with the tree style web page directory</sub>\r\n<p>Let\'s just start with the homepage <code>/</code>. It\'s actually okay in my opinion, probably the best page in the site. The tree style directory map looks decent in the center, making the command line design inspiration very clear. Overall I don\'t hate it, although it is useless because no one would need to go to it.</p>\r\n<img class=\"img-responsive\" src=\"/common/static/img/blog1.0-articles.png\" alt=\"image-alternative\"><sub>Figure 1: The articles page</sub>\r\n<p>Clicking on articles takes us to <code>/articles</code> and now we face the horror. This is pretty much what the entire site looks like. A harsh contrast of black and white making it very tough on the eyes. The command line design continues with the header showing a nice \'pwd\' which displays your current directory. The tree style pages do not suit the format of a sidebar, and makes it look out of place. If you click on an article, you can see that the sidebar will grow along with the length of the article, but the tree will stay at the top, making the left side wasted space. The design is pretty utilitarian (in the bad way) and makes no attempt to please the reader.</p>\r\n<p>That\'s all I have to say about the asthetics, I don\'t know how to properly critque this. I\'m not a designer by any means and this should have shown you why.</p>\r\n\r\n<h3 id=\"0x200\">0x200: The Logic</h3><hr>\r\n<p>Here is the real monster, the reason I haven\'t bothered to write any posts, and maybe even my worst attempt at designing a piece of software I\'ve ever written. I\'m not sure on where to even start, so many things are just wrong and inefficent.</p>\r\n<p>How about the things I didn\'t do? Continuing on from the intro, I didn\'t use any web frameworks with only Jinja as a templating engine and pure CGI magic with Apache rewrite rules to change the URL.</p>\r\n<p>What does this mean? It means that in order to get the blog\'s content to do what I wanted (which was to have each article be accessible from it\'s own URL instead of using a GET request with an ID for the database) the articles had to be in the <code>html</code> folder for Apache to serve them to the user. And since these articles were in the <code>html</code> folder and not <code>cgi-bin</code>, Jinja could not render them, which meant I had no templating for my articles. Of course this then meant that everytime I would have to make a change to the general layout of the blog, I would have do it to the layout for Jinja templating as well as every article in the <code>html</code> folder. Oh no.</p>\r\n<p>My <code>cgi-bin</code> scripts also suffered from this as I had to rewrite the URL for each page. Here\'s a small peak of my Apache config (since it isn\'t on GitHub).</p>\r\n<pre>\r\nRewriteEngine On\r\nRewriteRule ^/$ /index.html [PT]\r\n# Fix later\r\nRewriteRule ^/articles/$ /app/articles [PT]\r\nRewriteRule ^/articles/security$ /app/security [PT]\r\nRewriteRule ^/articles/misc$ /app/misc [PT]\r\nRewriteRule ^/info$ /app/info [PT]\r\nRewriteRule ^/contact-me$ /app/contact [PT]\r\n</pre>\r\n<p>Yeah, it isn\'t pretty. Note the fix later comment.</p>\r\n<p>This caused me a lot of work to be done on even the tinyest change, and really put me off on working on it. That is until I decided to burn it and start again.</p>\r\n\r\n<h3 id=\"0x300\">0x300: The Redesign</h3><hr>\r\n<p>What you are reading now is blog 2.0, the redesign. I\'ve made many improvements to make the website better to view and develop. The biggest change as you can imagine is the use of an actual web framework. The blog uses <a href=\"https://github.com/yevrah/simplerr\" target=\"_blank\">simplerr</a>, a framework one of my co-workers made, and one that I find easier to use than Flask (although that may be because I\'ve used it more). It\'s also using a Bootstrap template, so no more plain ugly.</p>\r\n<p>All of this and more such as the tagging system have been made 1 day faster (2 days) than what blog 1.0 took (3 days), which really shows how much easier using other people\'s stuff is. Obviously, there\'s much more to improve, but that is mainly on my side to make it easier to manage/write articles.</p>\r\n\r\n<h3 id=\"0x400\">0x400: What\'s Next</h3><hr>\r\n<p>A big feature that\'s standard of every blogging site is the ability to write articles on the site and then uploading it to the database. Right now I write it in HTML using Vim and then manually edit the database. This is pretty inefficent and it wouldn\'t be too hard to add a text editor to the site, but right now I do not want to deal with authentication (so that only I can see and upload in progess articles), so this feature is on hold. I simply do not post enough for this to be a major problem right now ;)</p>\r\n<p class=\"extra-info\"><b>Update 2018-05-31:</b> jks nvm that was easy. I didn\'t need auth, just set an environment variable for the production server, so you can only edit articles on dev machines.</p>','blog1.0-404.png','blogpost','no');
/*!40000 ALTER TABLE `Articles` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-05-31 11:26:53