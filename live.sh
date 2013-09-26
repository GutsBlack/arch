#!/bin/sh

#----------------------------------------------------------------
# Define config
#----------------------------------------------------------------

loadkeys fr # Keyboard FR
export LANG=fr_FR.UTF-8
blue="\\033[1;34m"
cyan="\\033[1;36m"
green="\\033[1;32m"
nc="\\033[0;39m"
red="\\033[1;31m"
white="\\033[1;37m"
yellow="\\033[1;33m"

DIALOG=${DIALOG=dialog}
INPUT=/tmp/menu$$
OUTPUT=/tmp/output$$
HDD=/tmp/hdd$$
DEF_SIZE_ROOT=0

# trap and delete temp files
trap "rm $OUTPUT; rm $INPUT; rm $HDD; rm $HDD_SIZE exit" SIGHUP SIGINT SIGTERM
clear




#----------------------------------------------------------------
# Launch SSH
#----------------------------------------------------------------

if [ ! -f /run/sshd.pid ]; then
	echo -e "$white Information :$cyan Lancement de SSH$nc"
	#/etc/rc.d/sshd start
	echo ""
fi




#----------------------------------------------------------------
# FUNCTION > SELECT HDD
#----------------------------------------------------------------

function select_hdd()
{
	$DIALOG --clear --backtitle "Installation de Archlinux" \
	--title "Indiquer le disque" --clear \
	--inputbox "\n(Exemple : sda) :" 16 51 2> $HDD

	DEF_HDD=$(<$HDD)
}




#----------------------------------------------------------------
# FUNCTION > SIZE ROOT
#----------------------------------------------------------------

function select_size_root()
{

		$DIALOG --clear --backtitle "Installation de Archlinux" \
		--title "Taille de la racine" --clear \
		--inputbox "\n(Exemple : 20 pour 20 Go) :" 16 51 2> $DEF_SIZE_ROOT

		DEF_SIZE_ROOT=$(<$DEF_SIZE_ROOT)

		# Convert Size.
		DEF_SIZE_ROOT=$((1+(1024*$DEF_SIZE_ROOT)))
}




#----------------------------------------------------------------
# FUNCTION > PARTITION
#----------------------------------------------------------------

function partition()
{
	# Max Size of /dev/sdX
	DEF_SIZE_MAX=$(( $(cat /sys/block/$DEF_HDD/size) * 512 / 1024 / 1024 - 1 ))

	# Create GPT HDD
	parted --script /dev/$DEF_HDD mklabel gpt

	# Create Bios Boot Partition for Bios Compatibility
	parted --script -a optimal /dev/$DEF_HDD unit MiB mkpart primary 1 2
	parted --script /dev/$DEF_HDD set 1 bios_grub on
	parted --script /dev/$DEF_HDD name 1 ArchBios

	# Create Root /
	parted --script -a optimal /dev/$DEF_HDD unit MiB mkpart primary 2 $DEF_SIZE_ROOT
	parted --script /dev/$DEF_HDD name 2 ArchRoot

	# Create Home /home
	parted --script -a optimal /dev/$DEF_HDD unit MiB mkpart primary $DEF_SIZE_ROOT $DEF_SIZE_MAX
	parted --script /dev/$DEF_HDD name 3 ArchHome
}




#----------------------------------------------------------------
# FUNCTION > PARTITION
#----------------------------------------------------------------

function format()
{
	if [ -f /dev/$DEF_HDD"2" ]; then
		"Echec de formatage sur /dev/$DEF_HDD""2"
	else
		echo -e "$white Formatage de : $green/dev/$DEF_HDD""2"$nc
		mkfs.ext4 /dev/$DEF_HDD"2"
	fi

	if [ $1 = "ALL" ]; then
		if [ -f /dev/$DEF_HDD"3" ]; then
			"Echec de formatage sur /dev/$DEF_HDD""3"
		else
			echo -e "$white Formatage de : $green/dev/$DEF_HDD""3"$nc
			mkfs.ext4 /dev/$DEF_HDD"3"
		fi
	fi
}




#----------------------------------------------------------------
# FUNCTION > INSTALL
#----------------------------------------------------------------

function installation()
{
	mount /dev/$DEF_HDD"2" /mnt && mkdir /mnt/{boot,home} # Mount /
	mount /dev/$DEF_HDD"3" /mnt/home # Mount /home

	if [ -d /mnt/boot ]; then
		clear
		echo -e "$white Installation du système de base  :$nc"
		pacstrap /mnt base base-devel vim net-tools "wget"

		echo -e "$white Installation de Grub2 :$nc"
		pacstrap /mnt grub-bios os-prober

		 # Create /etc/fstab
		echo -e "$white Création du fstab :$nc"
		genfstab -U -p /mnt >> /mnt/etc/fstab

		# Get Setup
		wget -P /mnt/root/ http://gutsblack.free.fr/arch/setup.sh
		chmod 755 /mnt/root/setup.sh

		clear
		echo -e "$white Lancer l'installation :$green /root/setup.sh$nc"

		# Chroot System
		arch-chroot /mnt
	else
		echo -e "$white Information :$red Une erreur est survenue !"$nc
		exit
	fi
}




#----------------------------------------------------------------
# FUNCTION > TOTAL
#----------------------------------------------------------------

function total()
{
	# Select HDD.
	select_hdd

	# Get Size Root.
	select_size_root

	# Partition HDD
	partition

	# Format All
	format "ALL"

	# Installation
	installation
}




#----------------------------------------------------------------
# FUNCTION > NORMAL
#----------------------------------------------------------------

function normal()
{
	# Select HDD.
	select_hdd

	# Format All
	format "ALL"

	# Installation
	installation
}




#----------------------------------------------------------------
# FUNCTION > HOME
#----------------------------------------------------------------

function home()
{
	# Select HDD.
	select_hdd

	# Format Root
	format "NONE"

	# Installation
	installation
}




#----------------------------------------------------------------
# Function > MENU
#----------------------------------------------------------------

function choice()
{
	dialog --clear  --help-button --backtitle "Installation de Archlinux" \
	--title "[ Menu principal ]" \
	--menu "\nBienvenue sur l'installation simplifié de Archlinux" 20 70 10 \
	Total "Installation complète (Partition+Formatage)" \
	Normal "Installation simple (Formatage uniquement)" \
	Home "Installation en conservant /home" \
	Exit "Quitter l'installation" 2>"${INPUT}"

	menuitem=$(<"${INPUT}")

	# make decsion 
	case $menuitem in
		Total) total;;
		Normal) normal;;
		Home) home;;
		Exit)
			if [ -d /mnt/boot ]; then
				umount /dev/$DEF_HDD"3"
				sleep 5
			fi

			if [ -d /mnt/home ]; then
				umount /dev/$DEF_HDD"2"
			fi

			exit

			echo "Bye !"; break;;
	esac
}

while :
do choice
done

exit

# if temp files found, delete em
[ -f $OUTPUT ] && rm $OUTPUT
[ -f $INPUT ] && rm $INPUT
[ -f $HDD ] && rm $HDD
[ -f $HDD_SIZE ] && rm $HDD_SIZE
