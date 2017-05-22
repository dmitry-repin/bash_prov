#!/bin/bash

main() {
  local backup_timestamp=$(date "+%Y-%m-%dT%H:%M:%S")
  local backup_path="${BACKUPS_ROOT}/${backup_timestamp}"
  
  # Ensure WWW_PATH exists exit otherwise
  [ -d "$WWW_PATH" ] || return 0
  
  # Ensure backup path exists
  [ -d "$backup_path" ] || sudo -u $WWW_USER mkdir -p "$backup_path"
  
  # Backup database
  local db_backup_path="${backup_path}/dump_${backup_timestamp}.sql.gz"
  sudo -u postgres pg_dump $PROJECT_NAME | gzip > "$db_backup_path"
  
  # Backup www files
  local link_dest
  local dir
  for dir in $DIRS_TO_BACKUP; do
    [ -d "${WWW_PATH}/${dir}/" ] || continue
    if [ -d "${BACKUPS_ROOT}/current" ]; then
      link_dest="--link-dest=${BACKUPS_ROOT}/current/${dir}"
    else
      link_dest=''
    fi
    if [ -n "$link_dest" ]; then
      rsync -aX "$link_dest" "${WWW_PATH}/${dir}/" "${backup_path}/${dir}"
    else
      rsync -aX "${WWW_PATH}/${dir}/" "${backup_path}/${dir}"
    fi
  done
  
  chown -R $WWW_USER:$WWW_GROUP -R "$backup_path"
  
  rm -f "${BACKUPS_ROOT}/current"
  sudo -u $WWW_USER ln -s "$backup_timestamp" "${BACKUPS_ROOT}/current"
}

main
