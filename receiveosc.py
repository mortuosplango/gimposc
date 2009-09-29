#!/usr/bin/env python

## Place it in your ~/gimp-2.6/plug-ins
##
## Needs SimpleOSC (http://www.ixi-audio.net/content/body_backyard_python.html)
## installed. Python wizards probably know how to install this correctly,
## I installed it via the instructions in the package, but had to place
## the "osc"-folder in ~/gimp-2.6/plug-ins to make it work.


import math
import osc

from gimpfu import *
from gimpshelf import shelf


# i18n
#
import gettext
locale_directory = gimp.locale_directory
gettext.install( "gimp20-template" , locale_directory, unicode=True )

receiveosc_help = _("Receive image as OSC-Message.")
receiveosc_description = _("ReceiveOSC")+" "+sendosc_help

def storeSpecs(*msg):
    global newPicWidth = msg[0][2]
    global newPicHeight = msg[0][3]
    global newPicBpp = msg[0][4]
    if newPicBpp == 2:
        global newPicMode = GRAY_IMAGE;
    else:
        global newPicMode = RGB_IMAGE;

def receiveImage(*msg):
    msg = msg[0]
    msg[0][0:2] = []
    for pixel in msg:
        pic.append(chr(pixel))

def displayImage(*msg):
    if msg[0][2] == -1:
        newLayer = gimp.Layer(inImage, "fromOSC", newPicWidth, newPicHeight, RGB_IMAGE, 100, NORMAL_MODE)
        newPic = newLayer.get_pixel_rgn(0,0,newPicWidth,newPicHeight, True)
        #newPic = pic
        newPic[0:newPicWidth,0:newPicHeight] = pic
        newPic.flush()  

def python_fu_receiveosc( inImage, inDrawable, netAddr="127.0.0.1",
                       port=57130):
    # save options
    shelf['oscport'] = [port]
    shelf['oscnetaddr'] = [netAddr]
    shelf['oscbflatten'] = [bFlatten]

    ## start communication: the specs of the picture to send
    global pic = []
    osc.init()
    osc.listen(netAddr, port)
    osc.bind(storeSpecs, "/gimp/spec")
    osc.bind(receiveImage, "/gimp/pic")
    osc.bind(displayImage, "/gimp/end")


    ## end communication:
    osc.sendMsg("/gimp", [-1], netAddr, port)
    osc.dontListen()

#    inImage.enable_undo()
    gimp.delete(newLayer)


register(
    "python_fu_sendosc",
    receiveosc_description,
    receiveosc_help,
    "Holger Ballweg",
    "GPL License",
    "2009",
    _("ReceiveOSC"),
    "RGB*,GRAY*",
    [
        (PF_IMAGE, "inImage", "Input image", None),
        (PF_DRAWABLE, "inLayer", "Input drawable", None),
        #(PF_BOOL, "bFlatten", "Flatten image?", False),
        (PF_STRING, "netAddr", _("IP-Address"), '127.0.0.1'),
        (PF_INT, "port", _("Port to send to"), 57130),
        ],
    [],
    python_fu_sendosc,
    menu="<Image>/Filters/Sound",
    domain=("gimp20-template", locale_directory) 
  )

main()
