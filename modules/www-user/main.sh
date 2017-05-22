#!/bin/bash

main() {
	local user_shell='/bin/bash'
	local user_homedir="/home/${WWW_USER}"
	
  # Create group if absent
	getent group $WWW_GROUP &> /dev/null || groupadd $WWW_GROUP
	
  # Create user if absent
	getent passwd $WWW_USER &> /dev/null || \
	  useradd -m -d "$user_homedir" -s "$user_shell" -g $WWW_GROUP $WWW_USER
	
  # Check user parameters if user exists
	
  # Check homedir
	[[ "$user_homedir" == $(getent passwd $WWW_USER | cut -d: -f6) ]] || \
	  usermod -d "$user_homedir" $WWW_USER
	[ -d "$user_homedir" ] || mkhomedir_helper $WWW_USER
	
  # Check user shell
	[[ "$user_shell" == $(getent passwd $WWW_USER | cut -d: -f7) ]] || \
	  usermod -s "$user_shell" $WWW_USER
	
  # Check gid
	current_gid=$(getent passwd $WWW_USER | cut -d: -f4)
	correct_gid=$(getent group $WWW_GROUP | cut -d: -f3)
	[[ $current_gid == $correct_gid ]] || \
	  usermod -g $correct_gid $WWW_USER
}

[[ $TARGET = $DEV ]] || main
