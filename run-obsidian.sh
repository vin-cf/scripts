#!/bin/bash
readonly DOCUMENTS_FOLDER="$HOME/Documents/"
readonly ENCRYPTED_VAULT="Obsidian-encrypted"
readonly DECRYPTED_VAULT="Obsidian"


is_mounted() {
    local mount_point="$1"

    if cat /proc/mounts | grep "$mount_point"; then
        echo "$mount_point is mounted."
        return 0  # Mounted
    else
        echo "$mount_point is not mounted."
        return 1  # Not mounted
    fi
}


mount_point="$DOCUMENTS_FOLDER$ENCRYPTED_VAULT"
while is_mounted "$mount_point"; do
    echo "$mount_point is mounted"
    umount -l "$mount_point"
    sleep 1  # Check every second
done

echo "Enter your gocryptfs password:"
read -s PASSWORD

echo $PASSWORD | gocryptfs -extpass "echo $PASSWORD" $DOCUMENTS_FOLDER$ENCRYPTED_VAULT $DOCUMENTS_FOLDER$DECRYPTED_VAULT > /dev/null 2>&1

EXIT_STATUS=$?

# Check if gocryptfs was successful
if [ $EXIT_STATUS -ne 0 ]; then
  echo "Error: Failed to mount gocryptfs. Incorrect password or other error."
  exit 1
fi


# Launch Obsidian
flatpak run md.obsidian.Obsidian

while flatpak ps | grep 'md.obsidian.Obsidian' >/dev/null; do
    sleep 1
done

# unmount
fusermount -u "$mount_point"
umount -f "$mount_point"

