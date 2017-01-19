#! /bin/bash

# From:
# http://www.filewatcher.com/p/xen-tools-4.0.3_04-45.1.x86_64.rpm.5340271/etc/xen/scripts/xmclone.sh.html

#     Script to clone Xen Dom-Us.
#     Based on XenClone by Glen Davis; rewritten by Bob Brandt.
#     Further extended and restructured by Manfred Hollstein.
#     Copyright (C) 2007  Manfred Hollstein, SUSE / Novell Inc.
#
#     This program is free software; you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation; either version 2 of the License, or
#     any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301
#     USA.

#
# Defaults
#
VERSION=0.4.5
XEN_CONFIGS=/etc/xen/vm/
XEN_BASE=/var/lib/xen/images/
SOURCE=
DESTINATION=
DUPLICATE=0
HOSTNAME=
IP=
MAC=
PART=2
DOMU_IS_FILE_BASED=
DOMU_ROOTDEV=
FORCE=no


#
# Subroutines used in this script
#

# Display the usage information for this script
function usage ()
{
	cat << EOF
Usage: ${0##*/} [-h|--help] [-v|--version] [--force] [-c dir] [-b dir] [-d]
		    [-n hostname] [-i address] [-m address]
		    [-p number-of-root-partition-within-domU]
		    [-t target-device]
		    SourcedomU NewdomU

Clones a domU, and gives a new Host name, MAC address and possibly IP address.
Once finished the new domU should boot without any additional configuration.
Currently works with single NIC, and basic bridge setup. Tested with cloning
a SLES10 install created from the SLES10 YaST Xen module.

  -h, --help	       Display this help message.
  -v, --version	       Display the version of this program.
  --force	       Silently overwrite files when destination already exists.
  -c		       Xen configuration directory which defaults to:
		       $XEN_CONFIGS
  -b		       Xen image base directory which defaults to:
		       $XEN_BASE
  -d		       Duplicate only, do not modify attributes.
  -n		       Hostname to be used, if not specified the NewdomU name
		       will be used.
  -i		       IP address to be used, if not specified the IP address
		       will not be changed.
  -m		       MAC address to be used, if not specified a psuedo-random
		       address will be used based on the ip address with the
		       format: 00:16:3e:BB:CC:DD
		       Where BB,CC,DD are the Hex octals of the IP address.
  -p		       This script assumes that the second partition on any
		       writable disk of the domU to be cloned holds the root
		       file system in which attributes have to be changed.
		       If this is not the case for you, you can specify the
		       partition number using this flag.
  -t		       If the SourcedomU uses a block device for its root/
		       boot directory, you need to specify the new block
		       device for NewdomU.

From XENSource Networking WIKI (http://wiki.xensource.com/xenwiki/XenNetworking)
Virtualised network interfaces in domains are given Ethernet MAC addresses. When
choosing MAC addresses to use, ensure you choose a unicast address. That is, one
with the low bit of the first octet set to zero. For example, an address
starting aa: is OK but ab: is not.
It is best to keep to the range of addresses declared to be "locally assigned"
(rather than allocated globally to hardware vendors). These have the second
lowest bit set to one in the first octet. For example, aa: is OK, a8: isn\'t.

Exit status is 0 if OK, 1 if minor problems, 2 if serious trouble.
EOF
}

# Display the version information for this script
function version ()
{
	cat << EOF
${0##*/} (Xen VM clone utility) $VERSION
${0##*/} comes with ABSOLUTELY NO WARRANTY.
This is free software, and you are welcome to redistribute it under the terms
of the GNU General Public License <http://www.gnu.org/licenses/gpl.html>.

Written by Manfred Hollstein, based on work by Glen Davis and Bob Brandt.
EOF
}

# Find/Replace text within a file
function replace ()
{
	sed -i -e "s!$1!$2!g" "$3"
}

#
# Find the first entry that names a writable image or device, assuming
# the Dom-U is going to boot from it:
#
function get_first_writable_image ()
{
	local i

	for i in $@
	do
		case $i in
		    # Match the first entry like "'phy:/dev/md0,xvda,w',"
		    *",w'," )
			# Strip off the leading "'" character:
			i="${i#*\'}"
		    	# Strip off the final trailing "',"
			echo "${i%*\',}"
			return
			;;
		esac
	done
}

#
# Extract just the protocol and the file/device name part from a disk entry:
#
function extract_proto_and_filename ()
{
	echo "$1" | cut -d, -f1
}


#
# Make sure this script is run by the superuser root
#
if [ `id -u` -ne 0 ]
then
	echo "You must be root to run this script!" >&2
	exit 1
fi


#
# Process the parameters
#
# Must look for double -- arguments before calling getopts
#
if [ "$1" = "--version" ]
then
	version
	exit 0
fi
if [ "$1" = "--help" ]
then
	usage
	exit 0
fi
if [ "$1" = "--force" ]
then
	FORCE=yes
	shift
fi
while getopts ":b:c:dhi:m:n:p:t:v" opt
do
	case $opt in
	    b )
		XEN_BASE=$OPTARG
		;;
	    c )
		XEN_CONFIGS=$OPTARG
		;;
	    d )
		DUPLICATE=1
		;;
	    h )
		usage
		exit 1
		;;
	    i )
		IP=$OPTARG
		;;
	    m )
		MAC=$OPTARG
		;;
	    n )
		HOSTNAME=$OPTARG
		;;
	    p )
		PART=$OPTARG
		;;
	    t )
		DOMU_ROOTDEV=$OPTARG
		;;
	    v )
		version
		exit 0
		;;
	esac
done
shift $(($OPTIND-1))

if [ $# -ne 2 ]
then
	echo "Illegal number of arguments passed!" >&2
	echo "" >&2
	usage
	exit 1
fi

SOURCE=$1
DESTINATION=$2


#
# Verify the Source and Destination parameters
#
# The source and destination should be relative directory names without
# trailing /'s.  If the source does have a full path, use that path as the
# value for XEN_BASE.  Otherwise remove all but the last part of the path
# for both source and destination
#
SOURCEDIR=${SOURCE%/*}
SOURCEBASE=${SOURCE##*/}
if [ "$SOURCEDIR" != "$SOURCEBASE" ]
then
	XEN_BASE=$SOURCEDIR"/"
	SOURCE=$SOURCEBASE
fi
SOURCE=${SOURCE##*/}
DESTINATION=${DESTINATION##*/}


#
# Verify the Xen Config and Source parameters
#
# Verify the validity of each argument, ask the user if there is a problem
while [ ! -d "$XEN_CONFIGS" ]
do
	cat << EOF >&2
$XEN_CONFIGS either does not exist or is not a directory.
Please enter a valid directory.
EOF
	read -e -p "Xen Configuration Directory? " XEN_CONFIGS
done
while [ ! -d "$XEN_BASE" ]
do
	cat << EOF >&2
$XEN_BASE either does not exist or is not a directory.
Please enter a valid directory.
EOF
	read -e -p "Xen Image Base Directory? " XEN_BASE
done

#
# Directories should have a / after them
#
[ "$XEN_CONFIGS" != "" ] &&	XEN_CONFIGS="${XEN_CONFIGS%/}/"
[ "$XEN_BASE" != "" ] &&	XEN_BASE="${XEN_BASE%/}/"


#
# Verify that actual image and configuration file exist
#
while :
do
	if [ ! -f "$XEN_CONFIGS$SOURCE" ]
	then
		echo "The $XEN_CONFIGS$SOURCE file does not exist." >&2
		echo "Please select a valid file." >&2
		FILES=
		for FILE in `ls $XEN_CONFIGS`
		do
			# If the entry is a file
			[ -f "$XEN_CONFIGS$FILE" ]	&&
			FILES="$FILES $XEN_CONFIGS$FILE"
		done
		if [ -z "$FILES" ]
		then
			echo "There are no suitable files beneath $XEN_CONFIGS" >&2
			exit 1
		fi
		echo "Files beneath $XEN_CONFIGS"
		select FILE in $FILES
		do
			if [ -f "$FILE" ]
			then
				SOURCE=${FILE##*/}
				break
			fi
			echo "Invalid Selection." >&2
		done
	else
		#
		# Figure out what type of image we're using:
		#
		BOOTENTRY=$(get_first_writable_image $(sed -n -e 's,^disk[ 	]*=[ 	]*\[\(.*\)\],\1,p' "$XEN_CONFIGS$SOURCE"))
		case "$BOOTENTRY" in
		    phy:* )
			DOMU_IS_FILE_BASED=no
			;;
		    file:* |	\
		    tap:aio:* )
			DOMU_IS_FILE_BASED=yes
			;;
		    * )
			echo "Don't know how to deal with the boot protocol/device you appear to be using: $BOOTENTRY" >&2
			echo "These are the ones this script supports: \"phy:*\", \"file:*\", \"tap:aio:*\"" >&2
			exit 1
			;;
		esac
	fi


	if [ ${DOMU_IS_FILE_BASED} = yes ]
	then
		if [ ! -d "$XEN_BASE$SOURCE" ]
		then
			echo "The directory $XEN_BASE$SOURCE is invalid." >&2
			echo "Please select another one." >&2
			FILES=
			for FILE in `ls $XEN_BASE`
			do
				# If the entry is a directory and
				#   it is not empty
				[ -d "$XEN_BASE$FILE" ]		&&
				[ "`ls $XEN_BASE$FILE`" != "" ]	&&
				FILES="$FILES $XEN_BASE$FILE"
			done
			if [ -z "$FILES" ]
			then
				echo "There are no suitable directories beneath $XEN_BASE" >&2
				exit 1
			fi
			echo "Directories beneath $XEN_BASE"
			select FILE in $FILES
			do
				if [ -d "$FILE" ]
				then
					SOURCE=${FILE##*/}
					break
				fi
				echo "Invalid Selection." >&2
			done
			continue
		fi
		break

	else	# DomU is using some block device
		while [ ! -b "${DOMU_ROOTDEV}" ] || [ ! -w "${DOMU_ROOTDEV}" ]
		do
			read -e -p "You need to specify a valid block device for the new target DomU: " DOMU_ROOTDEV
		done
		break

	fi
done
BOOTIMAGE="$(echo $BOOTENTRY | awk -F : '{ print $NF }' | sed -e 's:,[^,]*,[^,]*$::')"


#
# Verify that the destination location does not already have an image or
#  config file
#
while [ -z "$DESTINATION" ]
do
	echo "You have not specified a Destination." >&2
	read -e -p "New Destination? " DESTINATION
done
while :
do
	if [ -f "$XEN_CONFIGS$DESTINATION" ] && [ $FORCE = no ]
	then
		echo "The target configuration file $XEN_CONFIGS$DESTINATION already exists!" >&2
		read -e -p "Please select a new Destination? " DESTINATION
	fi
	if [ ${DOMU_IS_FILE_BASED} = yes ]
	then
		if [ -d "$XEN_BASE$DESTINATION" ] && [ $FORCE = no ]
		then
			echo "The target image location $XEN_BASE$DESTINATION already exists!" >&2
			read -p "Please select a new Destination? " DESTINATION
			continue
		fi
	fi
	break
done


#
# Verify the network parameters (if Duplicate Only was not selected)
#
if [ $DUPLICATE -eq 0 ]
then
	if [ -z "$HOSTNAME" ]
	then
		echo "You have not entered a host name.  If you wish to, enter one now." >&2
		read -p "New host name? (Default: $DESTINATION) " HOSTNAME
	fi
	[ -z "$HOSTNAME" ] && HOSTNAME=$DESTINATION

	if [ -z "$IP" ]
	then
		echo "You have not specified an IP Address.  If you wish to change the IP address, enter one now."
		read -p "New IP Address? " IP
	fi
	while [ -n "$IP" ] && [ "${IP/*.*.*.*/ok}" != "ok" ]
	do
		echo "The IP Address you specified is invalid.  If you wish, enter a new one now."
		read -p "New IP Address? " IP
		[ -z "$IP" ] && break
	done

	if [ -z "$MASK" ]
	then
		echo "You have not specified a network mask in bits. Please enter one now. Default is 24 "
		read -p "Network mask? " MASK 
	fi
	while [ -n "$MASK" ] && [ "${MASK/**/ok}" != "ok" ]
	do
		echo "The Network mask you specified is invalid.  If you wish, enter a new one now."
		read -p "Network mask? " MASK
		[ -z "$MASK" ] && MASK=24 
	done

	if [ -z "$MAC" ]
	then
		newMAC=""
		newMACtext="(format 01:23:45:67:89:AB)"
		# If the IP Address is specified and the MAC isn't, generate one.
		if [ -n "$IP" ]
		then
			octal1=${IP%%.*}
			IP=${IP#*.}
			octal2=${IP%%.*}
			IP=${IP#*.}
			octal3=${IP%%.*}
			octal4=${IP#*.}
			IP="$octal1.$octal2.$octal3.$octal4"
			octal1="00"`echo $octal1 16 o p | dc | tr '[:upper:]' '[:lower:]'`
			octal2="00"`echo $octal2 16 o p | dc | tr '[:upper:]' '[:lower:]'`
			octal3="00"`echo $octal3 16 o p | dc | tr '[:upper:]' '[:lower:]'`
			octal4="00"`echo $octal4 16 o p | dc | tr '[:upper:]' '[:lower:]'`
			newMAC="00:16:3e:"${octal2:(-2)}":"${octal3:(-2)}":"${octal4:(-2)}
			newMACtext="(default $newMAC)"
		fi
		echo "You have not specified a MAC Address.  If you wish to change the MAC address, enter one now."
		read -p "New MAC Address? $newMACtext " MAC
		[ -z "$MAC" ] && MAC=$newMAC
	fi

	while [ "$MAC" != "" ] && [ "${MAC/[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]:[[:xdigit:]][[:xdigit:]]/ok}" != "ok" ]
	do
		echo "The MAC Address you specified is invalid.  If you wish, enter a new one now."
		read -p "New MAC Address? (format 01:23:45:67:89:AB) " MAC
		[ -z "$MAC" ] && break
	done
else
	HOSTNAME=
	IP=
	MASK=
	MAC=
fi


#
# Make sure that the source VM is not running
#
xmid=`xm domid "$SOURCE" 2>/dev/null`
if [ $? -eq 0 ] && [ -n "$xmid" ] && [ -z "${xmid//[[:digit:]]/}" ]
then
	echo "domU $SOURCE is currently running on Xen, please shutdown before cloning." >&2
	echo "The command \"xm shutdown $xmid -w\" will shutdown the domU" >&2
	exit 1
fi


#
# Copy the Xen Config file
#
SOURCECONFIG="$XEN_CONFIGS$SOURCE"
DESTCONFIG="$XEN_CONFIGS$DESTINATION"
echo "Copying Configuration files"
if ! cp -fv "$SOURCECONFIG" "$DESTCONFIG"
then
	echo "The Config file $SOURCECONFIG could not be copied to $DESTCONFIG" >&2
	exit 1
fi


#
# Edit newly copied configuration file
#
echo "Editing config file ($DESTCONFIG), correcting the new domU Name."
if ! replace "$SOURCE" "$DESTINATION" "$DESTCONFIG"
then
	echo "Unable to change the domU name in $DESTCONFIG from $SOURCE to $DESTINATION" >&2
	exit 1
fi

if [ $DUPLICATE -eq 0 ]
then
	oldUUID=`grep "^uuid[ 	]*=.*$" $DESTCONFIG`
	if [ x"${oldUUID}" = x ]
	then
		echo 'uuid="'`uuidgen`'"' >> $DESTCONFIG
	else
		sed -i -e 's,^uuid[ 	]*=.*$,uuid="'`uuidgen`'",' $DESTCONFIG
	fi
fi

if [ $DUPLICATE -eq 0 ] && [ -n "$MAC" ]
then
	# Get the vif line in the config file
	oldMAC=`grep "vif[ 	]*=[ 	]*" $DESTCONFIG`
	# extract everything between the square brackets
	oldMAC=${oldMAC#*[}
	oldMAC=${oldMAC%*]}
	# using the single quotes as delimiters, get the second field
	#  (this script can only deal with one adapter!)
	oldMAC=`echo "$oldMAC" | cut -f2 -d\'`
	# remove the mac= from the beginning
	oldMAC=${oldMAC#mac=*}

	if ! replace "$oldMAC" "$MAC" "$DESTCONFIG"
	then
		echo "Unable to change the MAC address in $DESTCONFIG from ($oldMAC) to ($MAC)" >&2
		exit 1
	fi
fi


#
# Create and Copy image directory
#

if [ $DOMU_IS_FILE_BASED = yes ]
then
	SOURCEXEN="$XEN_BASE$SOURCE/"
	DESTXEN="$XEN_BASE$DESTINATION/"
	echo "Creating the new image directory $DESTXEN"
	if ! mkdir -pv --mode=755 "$DESTXEN"
	then
		echo "Unable to create the directory $DESTXEN" >&2
		exit 1
	fi
	echo "Copying complete image.  (This may take a few minutes!)"

	tar -C $SOURCEXEN -cSf - --exclude=lost+found `cd $SOURCEXEN; echo *` \
	| tar -C $DESTXEN -xvBSpf -
	if [ $? -ne 0 ]
	then
		echo "Unable to copy the images from $SOURCEXEN to $DESTXEN" >&2
		exit 1
	fi
else	# Deal with block devices
	if [ $DUPLICATE -eq 0 ]
	then
		echo "Editing config file ($DESTCONFIG), correcting the new domU root device name."
		if ! replace ":$BOOTIMAGE," ":$DOMU_ROOTDEV," "$DESTCONFIG"
		then
			echo "Unable to change the domU root device name in $DESTCONFIG from $BOOTIMAGE to $DOMU_ROOTDEV" >&2
			exit 1
		fi
	fi
	echo "Copying from source block device ($BOOTIMAGE) to the new target device ($DOMU_ROOTDEV)"
	echo "(This may take a few minutes!)"
	if ! dd if=$BOOTIMAGE of=$DOMU_ROOTDEV bs=4K
	then
		echo "Failed to copy from $BOOTIMAGE to $DOMU_ROOTDEV" >&2
		exit 1
	fi
fi


#
# The rest of the script only applies if we are actually making changes within
# the image
#
if [ $DUPLICATE -eq 0 ]
then
	#
	# Create a temporary directory name
	#
	tmpdir=$(mktemp -d)
	if [ $? -ne 0 ]
	then
		echo "Unable to create temporary directory $tmpdir." >&2
		exit 1
	fi

	if [ $DOMU_IS_FILE_BASED = yes ]
	then
		set -- $(echo $DESTXEN*)
	else
		set -- $(echo $DOMU_ROOTDEV)
	fi

	for DISKIMAGE
	do
		# Silently ignore any directories (lost+found comes to mind):
		[ -d $DISKIMAGE ] && continue

		#
		# Mount the newly copied image file
		#
		loopdev=''
		for dev in /dev/loop*
		do
			if [ ! -b "$dev" ]
			then
				continue
			fi

			status=$(losetup "$dev" 2>/dev/null) || status=''

			if [ ! "$status" ]
			then
				status=$(losetup $dev "$DISKIMAGE")
				if [ ! "$status" ]
				then
					kpartx -a $dev
					loopdev=$dev
					break
				fi
			fi
		done
		if [ ! "$loopdev" ]
		then
			echo "No loopback devices available." >&2
			exit 1
		fi

		echo -n "Trying to mount partition $PART of $DISKIMAGE ... "
		mapperdev=$(echo "$loopdev" | sed -e 's/dev\//dev\/mapper\//g')p$PART
		status=$(mount -o rw $mapperdev "$tmpdir")
		if [ "$status" ]
		then
			kpartx -d $loopdev
			losetup -d $loopdev
			continue
		fi
		echo "succeeded."

		pushd "$tmpdir" > /dev/null

		#
		# Find out if we are looking at SLE10
		#
		SLE10=
		if [ -f etc/SuSE-release ]
		then
			OSVER=`cat etc/SuSE-release | sed -n 1p | awk -F'(' '{ print $1 }' | sed 's/ $//g'`
			if [ "$OSVER" == "openSUSE 10" -o \
				"$OSVER" == "SUSE Linux Enterprise Server 10" -o \
				"$OSVER" == "SUSE Linux Enterprise Desktop 10" ]
			then
				SLE10=1
			fi
		fi

		#
		# Change the Network Configuration in the mounted image file
		#
		if [ -n "$MAC" ]
		then
			if [ -d etc/sysconfig/network/ ]
			then
				echo "Changing the Network configuration in the newly copied image."
				pushd "etc/sysconfig/network/" > /dev/null
				# Find the ifcfg-ethMACADDRESS file in the
				#  newly copied image
				ETH0=`ls | grep ifcfg-eth | cut -f1`
				if [ -z "$ETH0" ]
				then
					echo "Unable to find ethernet file in image file" 2>&1
					cd /tmp; umount "$tmpdir"; rmdir "$tmpdir"
					kpartx -d $loopdev
					losetup -d $loopdev
					exit 1
				fi
				if [ "$SLE10" ]
				then
					mv -f "$ETH0" ifcfg-eth-id-$MAC
				else
					sed -i -e "s,^LLADDR=.*$,LLADDR=\'$MAC\',"   \
						ifcfg-eth0
				fi
				popd > /dev/null
			fi

			if [ -d etc/udev/rules.d/ ]
			then
				# The 30-net_persistent_names.rules or 70-persistent-net.rules
				#  file controls which interface to use.
				# By removing the SUBSYSTEM== lines, we force
				#  the system to recreate it.
				pushd "etc/udev/rules.d/" > /dev/null
				if [ "$SLE10" ]
				then
					sed -i -e "/SUBSYSTEM==/d"	\
						30-net_persistent_names.rules
				else
					sed -i -e "/SUBSYSTEM==/d"	\
						70-persistent-net.rules
				fi
				popd > /dev/null
			fi
		fi

		#
		# Change the IP Address in the mounted image file
		#
		if [ -n "$IP" ]
		then
			if [ -d etc/sysconfig/network/ ]
			then
				echo "Modify the IP Address of the new domU."

				pushd "etc/sysconfig/network/" > /dev/null
				if [ "$SLE10" ]
				then
					sed -i -e "s,^IPADDR=.*$,IPADDR=$IP,"   \
						ifcfg-eth-id-$MAC
				else
					sed -i -e "s,^IPADDR=.*$,IPADDR=$IP/$MASK,"   \
						ifcfg-eth0
				fi
				popd > /dev/null
			fi
		fi

		#
		# Change the HOSTNAME and hosts files in the mounted image file
		#
		if [ -n "$HOSTNAME" ]
		then
			if [ -d "etc/" ]
			then
				echo "Changing HOSTNAME file to $HOSTNAME."

				pushd "etc/" > /dev/null
				# using the period as a delimiter, select the
				#  first entry for the hostname
				oldHOSTNAME=`cut -f1 -d\. HOSTNAME`
				if ! replace "$oldHOSTNAME" "$HOSTNAME" "HOSTNAME"
				then
					echo "Unable to change the HOSTNAME from $oldHOSTNAME to $HOSTNAME" >&2
					cd /tmp; umount "$tmpdir"; rmdir "$tmpdir"
					kpartx -d $loopdev
					losetup -d $loopdev
					exit 1
				fi
				FQDN=`cat HOSTNAME`

				# Add entries for the new domU to /etc/hosts,
				#  if it doesn't already include them:
				if ! egrep -q "[[:space:]]$FQDN[^[:alnum:]]" \
					hosts
				then
					echo "Changing hosts file."
					echo -e "$IP\t$FQDN $HOSTNAME" >> hosts
				fi
				popd > /dev/null
			fi
		fi

		popd > /dev/null
		umount "$tmpdir"
		kpartx -d $loopdev
		losetup -d $loopdev
	done

	rmdir "$tmpdir"
fi

echo "Clone is complete. domU $DESTCONFIG is ready to start!"
exit 0
