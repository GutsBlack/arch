#!/bin/sh
blue="\\033[1;34m"
cyan="\\033[1;36m"
green="\\033[1;32m"
nc="\\033[0;39m"
red="\\033[1;31m"
white="\\033[1;37m"
yellow="\\033[1;33m"


#----------------------------------------------------------------
# Define Global
#----------------------------------------------------------------

loadkeys fr # Keyboard FR
export LANG=fr_FR.UTF-8
clear


#----------------------------------------------------------------
# Config /etc/localtime
#----------------------------------------------------------------

if [ ! -f /etc/localtime ]; then

	ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
fi


#----------------------------------------------------------------
# Config /etc/hostname
#----------------------------------------------------------------

if [ ! -f /etc/hostname ]; then
	touch /etc/hostname
	echo "Archlinux" >> /etc/hostname
fi


#----------------------------------------------------------------
# Config /etc/vconsole.conf
#----------------------------------------------------------------

if [ ! -f /etc/vconsole.conf ]; then
	touch /etc/vconsole.conf
	echo "KEYMAP=fr" >> /etc/vconsole.conf
	echo "FONT=" >> /etc/vconsole.conf
	echo "FONT_MAP=" >> /etc/vconsole.conf
fi


#----------------------------------------------------------------
# Config keyboard Fr for GDM3
#----------------------------------------------------------------

if [ ! -f /etc/X11/xorg.conf.d/10-keyboard.conf ]; then
	mkdir /etc/X11/xorg.conf.d
	touch /etc/X11/xorg.conf.d/10-keyboard.conf
	echo 'Section "InputClass"' >> /etc/X11/xorg.conf.d/10-keyboard.conf
	echo '	Identifier         "Keyboard Layout"' >> /etc/X11/xorg.conf.d/10-keyboard.conf
	echo '	MatchIsKeyboard    "yes"' >> /etc/X11/xorg.conf.d/10-keyboard.conf
	echo '	MatchDevicePath    "/dev/input/event*"' >> /etc/X11/xorg.conf.d/10-keyboard.conf
	echo '	Option             "XkbLayout"  "fr"' >> /etc/X11/xorg.conf.d/10-keyboard.conf
	echo '	Option             "XkbVariant" "latin9"' >> /etc/X11/xorg.conf.d/10-keyboard.conf
	echo '	EndSection' >> /etc/X11/xorg.conf.d/10-keyboard.conf
fi


#----------------------------------------------------------------
# Config /etc/locale.conf
#----------------------------------------------------------------

if [ ! -f /etc/locale.conf ]; then
	touch /etc/locale.conf
	echo "LANG=fr_FR.utf8" >> /etc/locale.conf
	echo "LC_COLLATE=C" >> /etc/locale.conf
fi


#----------------------------------------------------------------
# Config /etc/timezone
#----------------------------------------------------------------

if [ ! -f /etc/timezone ]; then
	touch /etc/timezone
	echo "Europe/Paris" >> /etc/timezone
fi


#----------------------------------------------------------------
# Config /etc/locale.gen
#----------------------------------------------------------------

if [ ! -f /etc/locale.gen.old ]; then
	cp /etc/locale.gen /etc/locale.gen.old
	sed -i 's/^#fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen
	sed -i 's/^#fr_FR ISO-8859-1/fr_FR ISO-8859-1/' /etc/locale.gen
	locale-gen
fi


#----------------------------------------------------------------
# Create Root Passward and .bashrc
#----------------------------------------------------------------

if [ ! -f /root/.bashrc ]; then

	clear
	echo -e "$white Mot de passe root :$nc"
	passwd

	touch /root/.bashrc

	echo "alias ls='ls --color=auto'" >> /root/.bashrc
	echo "" >> /root/.bashrc
	echo 'cyan="\[\e[1;96m\]"' >> /root/.bashrc
	echo 'green="\[\e[1;32m\]"' >> /root/.bashrc
	echo 'purple="\[\e[1;35m\]"' >> /root/.bashrc
	echo 'red="\[\e[1;33m\]"' >> /root/.bashrc
	echo 'yellow="\[\e[1;31m\]"' >> /root/.bashrc
	echo 'white="\[\e[1;37m\]"' >> /root/.bashrc
	echo "" >> /root/.bashrc
	echo "#Alias Root" >> /root/.bashrc
	echo "alias ll='ls -l'" >> /root/.bashrc
	echo "alias la='ls -A'" >> /root/.bashrc
	echo "alias l='ls -CF'" >> /root/.bashrc
	echo "" >> /root/.bashrc
	echo "alias ai='pacman -S'" >> /root/.bashrc
	echo "alias ar='pacman -Rsn'" >> /root/.bashrc
	echo "alias aup='pacman -Syu'" >> /root/.bashrc
	echo "alias as='pacman -Ss'" >> /root/.bashrc
	echo "alias al='pacman -Qs'" >> /root/.bashrc
	echo "alias clean='pacman -Sc'" >> /root/.bashrc
	echo "" >> /root/.bashrc
	echo 'PS1="$white┌─ [$cyan\h : $(uname -r)$white] [$purple`date '+%H:%M'`$white] [$red\u$white] [$green\w$white]\n└──╼ \[\e[0m\]"' >> /root/.bashrc
	echo 'PS2="╾──╼ "' >> /root/.bashrc

	echo -e "$white Information :$red /root/$green .bashrc$white [fichier configuré]$nc"
	echo ""
	read -p "	Appuyer sur une touche pour continuer ..."
	clear
fi


#----------------------------------------------------------------
# Config /etc.pacman.conf
#----------------------------------------------------------------

if [ ! -f /etc/pacman.conf.old ]; then
	cp /etc/pacman.conf /etc/pacman.conf.old
	sed -i 's/^SigLevel    = Required DatabaseOptional/SigLevel = TrustedOnly/' /etc/pacman.conf
	sed -i 's/^#Color/Color/' /etc/pacman.conf
	sed -i 's|^#\[multilib\]|\[multilib\]\nInclude = /etc/pacman.d/mirrorlist|' /etc/pacman.conf
	sed -i '94d' /etc/pacman.conf
	echo [archlinuxfr] >> /etc/pacman.conf
	echo 'Server = http://repo.archlinux.fr/$arch' >> /etc/pacman.conf
	pacman -Syu --noconfirm
	pacman-key --init
	pacman-key --populate archlinux
fi


#----------------------------------------------------------------
# Config /etc/vimrc
#----------------------------------------------------------------

if [ ! -f /etc/vimrc.old ]; then
	cp /etc/vimrc /etc/vimrc.old
	sed -i 16i"syntax on" /etc/vimrc # Config Vim
fi


#----------------------------------------------------------------
# Edit Grub 2
#----------------------------------------------------------------

if [ ! -f /etc/default/grub.old ]; then
	cp /etc/default/grub /etc/default/grub.old

	grub-install --directory=/usr/lib/grub/i386-pc --target=i386-pc --boot-directory=/boot --recheck /dev/sda

	# Get Themes Archlinux
	wget -P /boot/grub/themes/ http://gutsblack.free.fr/arch/grub_archlinux.tar.gz
	tar xvzf /boot/grub/themes/grub_archlinux.tar.gz -C /boot/grub/themes/

	# Define Grub2 Config
	sed -i 's|^GRUB_TIMEOUT=5|GRUB_TIMEOUT=30|' /etc/default/grub
	sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT="quiet"|GRUB_CMDLINE_LINUX_DEFAULT="quiet console=tty1"|' /etc/default/grub # nouveau.modeset=1
	sed -i 's|^#GRUB_THEME="/path/to/gfxtheme"|GRUB_THEME="/boot/grub/themes/archlinux/theme.txt"|' /etc/default/grub

	# Create /etc/grub/grub.cfg
	grub-mkconfig -o /boot/grub/grub.cfg
fi


#----------------------------------------------------------------
# Create user
#----------------------------------------------------------------

clear
echo -e "$white Information :$cyan Créer un nouvel utilisateur ? $nc"

LISTE=("[o] oui" "[n] non")
select CHOIX in "${LISTE[@]}" ; do
case $REPLY in

	1|o)
		# Get user
		echo -e "$white Information :$cyan Entrer le nom de l'utilisateur a créer$nc"
		read DEF_USER

		# Add user
		useradd -m -g users -G audio,lp,optical,storage,video,wheel,games,power -s /bin/bash $DEF_USER

		# Get password
		passwd $DEF_USER

		echo -e "$white Information :$red Utilisateur$green $DEF_USER $white[ajouté]$nc"

		# Define home
		HOME="/home/$DEF_USER"

		if [ -f /home/$DEF_USER/.bashrc-old ]; then
			echo -e "$white Information : $white/home/$DEF_USER/"$green".bashrc $white[fichier présent]$nc"
		else

			# Create user .bashrc
			touch $HOME/.bashrc

			echo "" >> $HOME/.bashrc
			echo 'cyan="\[\e[1;96m\]"' >> $HOME/.bashrc
			echo 'green="\[\e[1;32m\]"' >> $HOME/.bashrc
			echo 'purple="\[\e[1;35m\]"' >> $HOME/.bashrc
			echo 'red="\[\e[1;33m\]"' >> $HOME/.bashrc
			echo 'yellow="\[\e[1;31m\]"' >> $HOME/.bashrc
			echo 'white="\[\e[1;37m\]"' >> $HOME/.bashrc
			echo "" >> $HOME/.bashrc
			echo "#Alias $DEF_USER" >> $HOME/.bashrc
			echo "alias ll='ls -l'" >> $HOME/.bashrc
			echo "alias la='ls -A'" >> $HOME/.bashrc
			echo "alias l='ls -CF'" >> $HOME/.bashrc
			echo "alias ..='cd ..'" >> $HOME/.bashrc
			echo "alias l.='ls -d .* --color=auto'" >> $HOME/.bashrc
			echo "alias home='cd /home/$DEF_USER'" >> $HOME/.bashrc
			echo "" >> $HOME/.bashrc
			echo "alias ai='yaourt -S'" >> $HOME/.bashrc
			echo "alias ar='yaourt -Rsn'" >> $HOME/.bashrc
			echo "alias aup='yaourt -Syu'" >> $HOME/.bashrc
			echo "alias as='yaourt -Ss'" >> $HOME/.bashrc
			echo "alias al='yaourt -Qs'" >> $HOME/.bashrc
			echo "alias clean='yaourt -Sc'" >> $HOME/.bashrc
			echo "" >> $HOME/.bashrc
			echo 'PS1="$white┌─ [$cyan\h : $(uname -r)$white] [$purple`date '+%H:%M'`$white] [$yellow\u$white] [$green\w$white]\n└──╼ \[\e[0m\]"' >> $HOME/.bashrc
			echo 'PS2="╾──╼ "' >> $HOME/.bashrc
			
			# Change Group.
			chown $DEF_USER:users $HOME/.bashrc

			# Create user user-dirs.dirs
			mkdir $HOME/.config
			chown $DEF_USER:users $HOME/.config
			touch $HOME/.config/user-dirs.dirs

			echo 'XDG_DESKTOP_DIR="$HOME/Bureau"' >> $HOME/.config/user-dirs.dirs
			echo 'XDG_DOWNLOAD_DIR="$HOME/Téléchargement"' >> $HOME/.config/user-dirs.dirs
			echo 'XDG_TEMPLATES_DIR="$HOME/Travail"' >> $HOME/.config/user-dirs.dirs
			echo 'XDG_PUBLICSHARE_DIR="$HOME/Public"' >> $HOME/.config/user-dirs.dirs
			echo 'XDG_DOCUMENTS_DIR="$HOME/Dropbox"' >> $HOME/.config/user-dirs.dirs
			echo 'XDG_MUSIC_DIR="$HOME/Musique"' >> $HOME/.config/user-dirs.dirs
			echo 'XDG_PICTURES_DIR="$HOME/Image"' >> $HOME/.config/user-dirs.dirs
			echo 'XDG_VIDEOS_DIR="$HOME/Vidéo"' >> $HOME/.config/user-dirs.dirs

			mkdir $HOME/Bureau
			mkdir $HOME/Téléchargement
			mkdir $HOME/Travail
			mkdir $HOME/Public
			mkdir $HOME/Document
			mkdir $HOME/Musique
			mkdir $HOME/Image
			mkdir $HOME/Vidéo

			chown $DEF_USER:users $HOME/Bureau
			chown $DEF_USER:users $HOME/Téléchargement
			chown $DEF_USER:users $HOME/Travail
			chown $DEF_USER:users $HOME/Public
			chown $DEF_USER:users $HOME/Document
			chown $DEF_USER:users $HOME/Musique
			chown $DEF_USER:users $HOME/Image
			chown $DEF_USER:users $HOME/Vidéo

			# Change Group.
			chown $DEF_USER:users $HOME/.config/user-dirs.dirs

			echo -e "$white Information : $red/home/$DEF_USER/"$green".bashrc $white[fichier créé]$nc"
			echo -e "$white Information : $red/home/$DEF_USER/"$green".config/user-dirs.dirs $white[fichier créé]$nc"
			echo ""
			read -p "	Appuyer sur une touche pour continuer ..."
			clear
		fi
	break
	;;

	2|n)
		echo -e "$white Information :$nc Entrez le nom de l'utilisateur actuel"
		read DEF_USER

		# Define home
		HOME="/home/$DEF_USER"
	break
	;;
	esac

done


#----------------------------------------------------------------
# Install Base system
#----------------------------------------------------------------

if [ ! -f /usr/bin/links ]; then
	clear
	echo -e "$white Installation :$nc Outils de base"
	pacman -S --noconfirm pulseaudio pulseaudio-alsa alsa-plugins ntfs-3g nfs-utils libdvdcss hddtemp yaourt openssh unrar p7zip lftp tilda mtools dosfstools numlockx flac vorbis-tools xdg-user-dirs "dialog" "zip" "unzip" links

	# Edit /etc/sudoers
	sed -i 's/^# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers

	echo -e "$white Installation :$green Outils de base $white[installé]$nc"
	echo -e "$white Information :$red /etc/"$green"sudoers $white[fichier configuré]$nc"
	echo ""
	read -p "	Appuyer sur une touche pour continuer ..."
	clear
fi


#----------------------------------------------------------------
# Install Base X.org
#----------------------------------------------------------------

if [ ! -f /usr/bin/startx ]; then
	echo -e "$white Installation :$nc X.org"
	pacman -S --noconfirm xorg-server xorg-xinit xorg-utils xorg-server-utils xorg-xauth xcursor-vanilla-dmz xterm libtxc_dxtn #lib32-libtxc_dxtn
	
	# Hack Cursor
	mkdir /usr/share/icons/default
	echo "[Icon Theme]" >> /usr/share/icons/default/index.theme
	echo "Inherits=Vanilla-DMZ" >> /usr/share/icons/default/index.theme

	#Install X11 Drivers [VESA, INTEL, NVIDIA, ATI]
	echo -e "$white Installation :$nc X11 Drivers"
	pacman -S --noconfirm xf86-video-fbdev xf86-video-vesa xf86-video-intel xf86-video-nouveau nouveau-dri xf86-video-ati #libva-driver-intel

	echo -e "$white Installation :$green X.org / Driver$white [installé]$nc"
	echo ""
	read -p "	Appuyer sur une touche pour continuer ..."
	clear
fi


#----------------------------------------------------------------
# Install Base Fonts TTF
#----------------------------------------------------------------

if [ ! -f /usr/share/fonts/TTF/LiberationSans-Regular.ttf ]; then
	echo -e "$white Installation :$nc Fonts TTF"
	pacman -S --noconfirm xorg-fonts-type1 ttf-dejavu artwiz-fonts font-bh-ttf font-bitstream-speedo gsfonts sdl_ttf ttf-bitstream-vera ttf-cheapskate ttf-liberation

	echo -e "$white Installation :$green Fonts TTF$white [installé]$nc"
	echo ""
	read -p "	Appuyer sur une touche pour continuer ..."
	clear
fi


#----------------------------------------------------------------
# Install Bureau
#----------------------------------------------------------------

echo -e "$white Information :$nc Installation du bureau ?"

LISTE=("[g] Gnome 3" "[h] Gnome 3 Lite" "[k] KDE 4" "[x] XFCE 4" "[l] Light" "[n] non")
select CHOIX in "${LISTE[@]}" ; do
case $REPLY in

	1|g)
		echo -e "$white Installation :$nc Gnome 3"
		pacman --noconfirm -S gnome gnome-clocks gnome-photos gnome-tweak-tool gamin nautilus-open-terminal cheese gst-libav file-roller network-manager-applet bluez4 ffmpeg filezilla cairo-dock-plugins gstreamer0.10-ffmpeg gstreamer0.10-ugly-plugins gstreamer0.10-bad-plugins evolution telepathy-mission-control telepathy-gabble telepathy-haze gimp gedit-plugins gthumb gvfs-smb gtk-engine-murrine gnome-documents gnote testdisk soundconverter kid3 faenza-icon-theme faience-icon-theme

		# Update XDG User dirs
		xdg-user-dirs-update
	
		# Set Numlock ON
		sed -i 89i"numlockx on" /etc/gdm/Init/Default

		systemctl enable gdm.service

		echo -e "$white Installation :$green Gnome 3.x$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour continuer ..."
		clear
	break
	;;

	2|h)
		echo -e "$white Installation :$nc Gnome 3 Lite"
		pacman --noconfirm -S gnome gnome-tweak-tool gamin nautilus-open-terminal cheese gst-libav file-roller network-manager-applet ffmpeg gstreamer0.10-ffmpeg gstreamer0.10-ugly-plugins gstreamer0.10-bad-plugins evolution epiphany telepathy-mission-control telepathy-gabble telepathy-haze gedit gthumb eog gvfs-smb gtk-engine-murrine gnome-documents

		# Update XDG User dirs
		xdg-user-dirs-update
	
		# Set Numlock ON
		sed -i 89i"numlockx on" /etc/gdm/Init/Default

		systemctl enable gdm.service

		echo -e "$white Installation :$green Gnome 3.x$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour continuer ..."
		clear
	break
	;;

	3|k)
		echo -e "$white Installation :$nc KDE 4"
		pacman --noconfirm -S kdebase kdebase-workspace kde-l10n-fr aspell-fr oxygen-gtk3 phonon phonon-gstreamer kid3 kwebkitpart network-manager-applet bluez4 ffmpeg gstreamer0.10-ffmpeg gstreamer0.10-ugly-plugins gstreamer0.10-bad-plugins

		# Update XDG User dirs
		xdg-user-dirs-update

		systemctl enable kdm.service

		echo -e "$white Installation :$green KDE 4.x$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour continuer ..."
		clear
	break
	;;

	4|x)
		echo -e "$white Installation :$nc XFCE 4"
		pacman --noconfirm -S xfce4 xfce4-goodies gamin slim slim-themes archlinux-themes-slim

		sed -i 's/^# numlock             on/numlock             on/' /etc/slim.conf
		sed -i 's/^current_theme       default/current_theme       archlinux-simplyblack/' /etc/slim.conf

		touch $HOME/.xinitrc
		chown $DEF_USER:users $HOME/.xinitrc
		echo "#!/bin/sh" >> $HOME/.xinitrc
		echo "exec startxfce4" >> $HOME/.xinitrc

		# Update XDG User dirs
		xdg-user-dirs-update

		systemctl enable slim.service

		echo -e "$white Installation :$green XFCE 4.x$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour continuer ..."
		clear
	break
	;;

	5|l)
		echo -e "$white Installation :$nc Light"
		yaourt --noconfirm -S lightdm-pantheon-greeter-bzr gala-bzr cerbere-bzr wingpanel-bzr slingshot-launcher geary scratch-text-editor-bzr pantheon-session-bzr pantheon-wallpaper-bzr pantheon-terminal nautilus midori aria2 noise-bzr umplayer maya-calendar-bzr elementary-icons elementary-gtk-theme elementary-scan-bzr cheese network-manager-applet #dexter-bzr plank-bzr

		#mkdir $HOME/.config/openbox
		#cp /etc/xdg/openbox/{menu.xml,rc.xml,autostart.sh} $HOME/.config/openbox/
		#chown $DEF_USER:users $HOME/.config/openbox

		#touch $HOME/.xinitrc
		#chown $DEF_USER:users $HOME/.xinitrc
		#echo "#!/bin/sh" >> $HOME/.xinitrc
		#echo "exec startlxde" >> $HOME/.xinitrc

		# Update XDG User dirs
		xdg-user-dirs-update

		#systemctl enable slim.service

		echo -e "$white Installation :$green Light$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour continuer ..."
		clear
	break
	;;

	6|n)
		clear
	break
	;;
	esac

done


#----------------------------------------------------------------
# Install Web Navigator
#----------------------------------------------------------------

echo -e "$white Information :$nc Navigateur Internet ?"

LISTE=("[f] Firefox" "[c] Chromium" "[n] non")
select CHOIX in "${LISTE[@]}" ; do
case $REPLY in

	1|f)
		echo -e "$white Installation :$nc Firefox"
		pacman -S --noconfirm firefox-i18n-fr

		echo -e "$white Installation :$green Firefox$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;
	2|c)
		echo -e "$white Installation : Chromium$nc"
		pacman -S --noconfirm chromium

		echo -e "$white Installation :$green Chromium$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	3|n)
		clear
	break
	;;
	esac

done


#----------------------------------------------------------------
# Install Suite Office
#----------------------------------------------------------------

echo -e "$white Information :$nc Suite Bureautique ?"

LISTE=("[l] LibreOffice" "[g] Suite Gnome" "[n] non")
select CHOIX in "${LISTE[@]}" ; do
case $REPLY in

	1|l)
		echo -e "$white Installation :$nc LibreOffice"
		pacman -S --noconfirm libreoffice-common libreoffice-fr libreoffice-gnome libreoffice-writer libreoffice-calc libreoffice-draw libreoffice-math

		echo -e "$white Installation :$green LibreOffice$white [installé]"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	2|g)
		echo -e "$white Installation :$nc Gnome Office"
		pacman -S --noconfirm abiword gnumeric

		echo -e "$white Installation :$green Suite Gnome$white [installé]"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	3|n)
		clear
	break
	;;
	esac

done


#----------------------------------------------------------------
# Install Audio Player
#----------------------------------------------------------------

echo -e "$white Information :$nc Lecteur Audio ?"

LISTE=("[r] Rhythmbox" "[c] Clementine" "[m] MPD" "[n] non")
select CHOIX in "${LISTE[@]}" ; do
case $REPLY in

	1|r)
		echo -e "$white Installation :$nc Rhytmbox"
		pacman -S --noconfirm rhythmbox

		echo -e "$white Installation :$green Rhythmbox$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	2|c)
		echo -e "$white Installation :$nc Clementine"
		pacman -S --noconfirm clementine

		echo -e "$white Installation :$green Clementine$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	3|m)
		echo -e "$white Installation :$nc MPD"
		pacman -S --noconfirm mpd ncmpc gmpc

		##CONFIG FILE ##
		sed -i 's/^music_directory		"~/music"/music_directory		"/home/gutsblack/Musique"/' /etc/mpd.conf
		sed -i 's/^user "mpd"/#user "mpd"/' /etc/mpd.conf
		sed -i 's/^#bind_to_address		"any"/bind_to_address		"127.0.0.1"/' /etc/mpd.conf
		sed -i 's/^#auto_update	"yes"/auto_update	"yes"/' /etc/mpd.conf
		sed -i 's/^#auto_update_depth "3"/auto_update_depth "3"/' /etc/mpd.conf

		echo -e "$white Installation :$green MPD$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	4|n)
		clear
	break
	;;
	esac

done


#----------------------------------------------------------------
# Install Plugins
#----------------------------------------------------------------

echo -e "$white Information :$nc Installer les plugins (Java, Flash...) ?"

LISTE=("[o] oui" "[n] non")
select CHOIX in "${LISTE[@]}" ; do
case $REPLY in

	1|o)
		echo -e "$white Installation :$nc Plugins"
		pacman -S --noconfirm flashplugin jre7-openjdk icedtea-web-java7 minitube umplayer nautilus-dropbox conky-colors

		yaourt -S --noconfirm minitube umplayer nautilus-dropbox conky-colors zukitwo-themes
		chmod u+s /usr/sbin/hddtemp

		echo -e "$white Installation :$green Plugins$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	2|n)
		clear
	break
	;;
	esac

done


#----------------------------------------------------------------
# Install Virtualbox
#----------------------------------------------------------------

echo -e "$white Information :$nc Installer virtualisation ?"

LISTE=("[v] Virtualbox" "[k] KVM/QEMU" "[n] non")
select CHOIX in "${LISTE[@]}" ; do
case $REPLY in

	1|v)
		echo -e "$white Installation :$nc Virtualbox"
		pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-guest-modules virtualbox-host-modules

		# Add Group Auth
		gpasswd -a $DEF_USER vboxusers
	
		# Add Daemons vboxdrv
		touch /etc/modules-load.d/virtualbox.conf
		echo "vboxdrv" >> /etc/modules-load.d/virtualbox.conf
		echo "vboxnetflt" >> /etc/modules-load.d/virtualbox.conf

		echo -e "$white Installation :$green Virtualbox$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	2|k)
		echo -e "$white Installation :$nc KVM/QEMU"
		pacman -S --noconfirm virt-manager dnsmasq qemu

		# Add Daemons virtd
		systemctl enable libvirtd

		echo -e "$white Installation :$green Virtualbox$white [installé]$nc"
		echo ""
		read -p "	Appuyer sur une touche pour terminer ..."
		clear
	break
	;;

	3|n)
		clear
	break
	;;
	esac

done


#----------------------------------------------------------------
# Enable SystemD Service
#----------------------------------------------------------------

systemctl enable NetworkManager.service
systemctl enable bluetooth.service
systemctl enable sshd.service
systemctl enable nfsd.service
#systemclt enable rpc-statd


#----------------------------------------------------------------
# Final Config
#----------------------------------------------------------------

mkinitcpio -p linux


#----------------------------------------------------------------
# Exit Chroot System
#----------------------------------------------------------------

clear
echo -e "$white Installation :$green terminé !$nc tapez$white exit$nc et pour finir$white reboot$nc pour redémarrer :D"
exit
