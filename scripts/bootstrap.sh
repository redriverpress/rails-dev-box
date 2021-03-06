# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.

export VAGRANT_HOME="/home/vagrant"
export VAGRANT_PATH="/home/vagrant/.zshrc"
export RBENV_ROOT="/home/vagrant/.rbenv"

function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo updating package information
add-apt-repository ppa:git-core/ppa >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential
install 'environment tools' autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
install 'verification tools' phantomjs qt5-default libqt5webkit5-dev

install Git git
echo .DS_Store >> $VAGRANT_HOME/.gitignore

install SQLite sqlite3 libsqlite3-dev
install Memcached memcached
install Redis redis-server
install RabbitMQ rabbitmq-server

install PostgreSQL postgresql postgresql-contrib libpq-dev
sudo -u postgres createuser --superuser vagrant
sudo -u postgres createdb -O vagrant activerecord_unittest
sudo -u postgres createdb -O vagrant activerecord_unittest2

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
install MySQL mysql-server libmysqlclient-dev
sed -i "s/^bind-address/#bind-address/" /etc/mysql/my.cnf >/dev/null 2>&1
mysql -uroot -proot <<SQL
CREATE USER 'rails'@'localhost';
CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION; FLUSH PRIVILEGES;
SQL
service mysql restart >/dev/null 2>&1

install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'ExecJS runtime' nodejs

install ZShell zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git $VAGRANT_HOME/.oh-my-zsh >/dev/null 2>&1
cp $VAGRANT_HOME/.oh-my-zsh/templates/zshrc.zsh-template $VAGRANT_PATH
chsh -s /bin/zsh vagrant

echo installing Rbenv
git clone git://github.com/sstephenson/rbenv.git $VAGRANT_HOME/.rbenv >/dev/null 2>&1
echo 'export PATH="/home/vagrant/.rbenv/bin:$PATH"' >> $VAGRANT_PATH
echo 'eval "$(rbenv init -)"' >> $VAGRANT_PATH

git clone git://github.com/sstephenson/ruby-build.git $VAGRANT_HOME/.rbenv/plugins/ruby-build >/dev/null 2>&1
echo 'export PATH="/home/vagrant/.rbenv/plugins/ruby-build/bin:$PATH"' >> $VAGRANT_PATH
source $VAGRANT_PATH >/dev/null 2>&1

echo installing Rubies
rbenv install 2.1.2 >/dev/null 2>&1
rbenv global 2.1.2

echo installing Bundler
gem install bundler >/dev/null 2>&1

chown -R vagrant $VAGRANT_HOME

echo enhancing PATH
echo 'export ZEUSSOCK=/tmp/zeus.sock' >> $VAGRANT_PATH

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8


echo 'all set, rock on!'
