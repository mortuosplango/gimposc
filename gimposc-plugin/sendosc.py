#!/usr/bin/env python

## Place it in your ~/gimp-2.6/plug-ins
##
## Needs SimpleOSC
## ( http://www.ixi-audio.net/content/body_backyard_python.html )
## Python wizards probably know how to install this correctly,
## I installed it via the instructions in the package, but had to place
## the "osc"-folder in ~/gimp-2.6/plug-ins to make it work.


import math
import osc
import socket
import time

from gimpfu import *
from gimpshelf import shelf


# i18n
#
import gettext
locale_directory = gimp.locale_directory
gettext.install( "gimp20-template" , locale_directory, unicode=True )

sendosc_help = _("Send image as OSC-Message.")
sendosc_description = _("SendOSC")+" "+sendosc_help

def python_fu_sendosc( inImage, inDrawable,
                       bFlatten=True,
                       netAddr="127.0.0.1",
                       port=57120):
    global outSocket
    ## save options for use with the guiless version
    shelf['oscport'] = [port]
    shelf['oscnetaddr'] = [netAddr]
    shelf['oscbflatten'] = [bFlatten]

    width = inDrawable.width
    height = inDrawable.height
    
    if bFlatten == True:
        inImage.disable_undo()
        flatImage = inImage.duplicate()
        flatImage.flatten()
        pr = flatImage.active_layer.get_pixel_rgn(0,0,width,height,False)
    else:
        pr = inDrawable.get_pixel_rgn(0,0,width,height,False)

    ## start communication and send specs
    osc.init()
    osc.sendMsg("/gimp/spec",
                [width, height, pr.bpp],
                netAddr, port)

    ## create an extra socket for the binary messages
    outSocket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    prp = pr[0:width,0:height]
    ## print(osc.hexDump(prp))
    gimp.progress_init("Sending image...")

    ## empirical maximum size: 65487 (2 ** 16 - 49)
    ## UDP-Datagram-Limit:
    ## The practical limit for the data length which is imposed by the
    ## underlying IPv4 protocol is 65,507 bytes.
    ## http://en.wikipedia.org/wiki/User_Datagram_Protocol#Packet_structure
    maxSize = 64000
    imgSize = width * height * pr.bpp
    for index in range( int(math.ceil(imgSize / float(maxSize))) ):
        m = osc.OSCMessage()
        m.address = "/gimp"
        m.append(index)
        if (((index + 1) * maxSize) > imgSize):
            m.append(prp[(index * maxSize):],'b')
        else:
            m.append(prp[(index * maxSize):((index + 1) * maxSize)],'b')
        outSocket.sendto( m.getBinary(), (netAddr, port))
        ## introduce latency to not loose packages
        time.sleep(0.02)

    ## end communication
    osc.sendMsg("/gimp", [-1], netAddr, port)
    ## clean up
    if bFlatten == True:
        inImage.enable_undo()
        gimp.delete(flatImage)


register(
    "python_fu_sendosc",
    sendosc_description,
    sendosc_help,
    "Holger Ballweg",
    "GPL License",
    "2009",
    _("SendOSC"),
    "RGB*,GRAY*",
    [
        (PF_IMAGE, "inImage", "Input image", None),
        (PF_DRAWABLE, "inLayer", "Input drawable", None),
        (PF_BOOL, "bFlatten", "Flatten image?", True),
        (PF_STRING, "netAddr", _("IP-Address"), '127.0.0.1'),
        (PF_INT, "port", _("Port to send to"), 57120),
        ],
    [],
    python_fu_sendosc,
    menu="<Image>/Filters/Sound",
    domain=("gimp20-template", locale_directory) 
  )

main()
