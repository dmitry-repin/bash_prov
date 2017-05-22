# THE_PROJECT website provisioning

## Requirements

* [Vagrant](https://www.vagrantup.com/) v1.9.3 or above
* [VirtualBox](https://www.virtualbox.org/) v5.1 or above

## Provisioning

Current provisioning implementation is supposed to be run on Ubuntu 16.04 only.
You may run it on another Ubuntu version or even the different OS but be aware
of 'Unsupported ... version' and 'Unsupported operating system' warnings. After
you've seen one of these warnings the provisioning process will halt.
	

### Vagrant

#### Installation

To run the vagrant VM just `cd` to the repository on the host and run:
```
	$ vagrant up
```
That's all. Just wait until provisioning finishes.

#### Access

##### Website

After you've finished with provisioning you should be able to access the
website on your host at the following addresses:

* http://dev.THE_PROJECT.com:8080
* http://localhost:8080 

It is recommended that you add a record to your `hosts` file on the host:
```
	127.0.0.1	dev.THE_PROJECT.com
```
BTW, you also should be able to access the site with the http://localhost:8000
on your host when you run the development server with the following commands:
```
    pyenv shell 3.5.3
    pyenv virtualenvwrapper
    workon THE_PROJECT
    cd /vagrant/THE_PROJECT
    ./manage.py runserver 0.0.0.0:8000
```

##### Django Superuser

You don't have to create the django superuser explicitly during the "vagrant"
provisioning. Provisioning scripts will create this user for you and then
you'll be able to access its web interface using "admin/admin" credentials.

### Staging / Production

1. Clone the repo to the local directory in your homedir on a server.
2. cd to that directory and run:

```
	$ sudo ./bootstrap.sh
	$ sudo ./provision.sh <stage|prod> 
```
That's all. Then you may create the django superuser and start using the
website.

Also you may perform these actions on your Vagrant VM to test the staging or
production provisioning on your dev environment.

### Supplementary files

There're some files we can't provide with the git repo. These files should be
placed in the */home/vagrant/THE_PROJECT/supplementary/* or 
*/home/www-data/THE_PROJECT/supplementary/* directory before the provisioning
started.

#### local.py
*local.py* is for the local Django settings. It should be placed in the
*/home/www-data/THE_PROJECT/supplementary/django/* directory. During the staging or
production (but not the dev!) provisioning it will be copied to the 
*/var/www/THE_PROJECT/THE_PROJECT/THE_PROJECT/settings/* directory.

### How to restore from backup

Threre is an ability to restore the database and www content from a backup
during provisioning. You will need a proper (that is created with the
provisioning backup script) backup copy placed in any directory on your
server. After you got your backup in the proper place just run:
```
	$ sudo ./provision.sh -r <path_to_backup_dir> <target> 
```
where *path_to_backup_dir* is a directory where backup content is placed and
*target* is one from the list of: *dev*, *stage*, *prod*.

But be aware of the following: Django project won't be restored despite
its presence in the backup directory. Only the project from a git repo will
be used after the provisioning process completed.
