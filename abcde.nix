{ writeText, abcde, cddiscid, cdparanoia, ffmpeg, flac, glyr }:

writeText "abcde-config" ''
# Encode tracks immediately after reading. Saves disk space, gives
# better reading of 'scratchy' disks and better troubleshooting of
# encoding process but slows the operation of abcde quite a bit:
LOWDISK=n

# Specify the method to use to retrieve the track information,
# the alternative is to specify 'musicbrainz':
CDDBMETHOD=musicbrainz
GLYRC=glyrc

# Make a local cache of cddb entries and then volunteer to use
# these entries when and if they match the cd:
CDDBCOPYLOCAL="y"
CDDBLOCALDIR="$HOME/.cddb"
CDDBLOCALRECURSIVE="y"
CDDBUSELOCAL="y"

# Specify encoders
AACENCODERSYNTAX=ffmpeg
FLACENCODERSYNTAX=flac

FLAC=${flac}/bin/flac
FFMPEG=${ffmpeg}/bin/ffmpeg
GLYRC=${glyr}/bin/glyrc

FLACOPTS='-s -e -V -8'
FFMPEGENCOPTS="-c:a aac -b:a 192k"

OUTPUTTYPE="flac,m4a"

# The cd ripping program to use. There are a few choices here: cdda2wav,
# dagrab, cddafs (Mac OS X only) and flac. New to abcde 2.7 is 'libcdio'.
CDROMREADERSYNTAX=cdparanoia

# Give the location of the ripping program and pass any extra options,
# if using libcdio set 'CD_PARANOIA=cd-paranoia'.
CDPARANOIA=${cdparanoia}/bin/cdparanoia
CDPARANOIAOPTS="--never-skip=40"

# Give the location of the CD identification program:
CDDISCID=${cddiscid}/bin/cd-discid

# Give the base location here for the encoded music files.
OUTPUTDIR="$HOME/Music"

# The default actions that abcde will take.
ACTIONS=cddb,read,getalbumart,encode,tag,move,playlist,clean

# Decide here how you want the tracks labelled for a standard 'single-artist',
# multi-track encode and also for a multi-track, 'various-artist' encode:
OUTPUTFORMAT='$(OUTPUT)/$(ARTISTFILE)-$(ALBUMFILE)/$(TRACKNUM).$(TRACKFILE)'
VAOUTPUTFORMAT='$(OUTPUT)/Various-$(ALBUMFILE)/$(TRACKNUM).$(ARTISTFILE)-$(TRACKFILE)'

# Decide here how you want the tracks labelled for a standard 'single-artist',
# single-track encode and also for a single-track 'various-artist' encode.
# (Create a single-track encode with 'abcde -1' from the commandline.)
ONETRACKOUTPUTFORMAT='$(OUTPUT)/$(ARTISTFILE)-$(ALBUMFILE)/$(ALBUMFILE)'
VAONETRACKOUTPUTFORMAT='$(OUTPUT)/Various-$(ALBUMFILE)/$(ALBUMFILE)'

# Create playlists for single and various-artist encodes. I would suggest
# commenting these out for single-track encoding.
PLAYLISTFORMAT='$(OUTPUT)/$(ARTISTFILE)-$(ALBUMFILE)/$(ALBUMFILE).m3u'
VAPLAYLISTFORMAT='$(OUTPUT)/Various-$(ALBUMFILE)/$(ALBUMFILE).m3u'

# This function takes out dots preceding the album name, and removes a grab
# bag of illegal characters. It allows spaces, if you do not wish spaces add
# in -e 's/ /_/g' after the first sed command.
mungefilename ()
{
  echo "$@" | sed -e 's/^\.*//' -e 's/ /_/g' | tr -d ":><|*/\"'?[:cntrl:]"
}

MAXPROCS=6                                # Run a few encoders simultaneously
PADTRACKS=y                               # Makes tracks 01 02 not 1 2
EXTRAVERBOSE=2                            # Useful for debugging
COMMENT='abcde version 2.7.2'             # Place a comment...
EJECTCD=y
''
