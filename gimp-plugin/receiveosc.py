#!/usr/bin/env python

## Place it in your ~/gimp-2.6/plug-ins
##
## Needs SimpleOSC (http://www.ixi-audio.net/content/body_backyard_python.html)
## installed. Python wizards probably know how to install this correctly,
## I installed it via the instructions in the package, but had to place
## the "osc"-folder in ~/gimp-2.6/plug-ins to make it work.


import math
import osc
import threading

from gimpfu import *
from gimpshelf import shelf

#from time import time, sleep
import time

# i18n
#
import gettext
locale_directory = gimp.locale_directory
gettext.install( "gimp20-template" , locale_directory, unicode=True )

receiveosc_help = _("Receive image as OSC-Message.")
receiveosc_description = _("ReceiveOSC")+" "+receiveosc_help

newSpecs = []
receiving = 0
pic = ''

def python_fu_receiveosc_storeSpecs(*msg):
    global newSpecs,receiving
    receiving = 2
    newSpecs = msg[0][2:5]
    if newSpecs[2] == 1:
        newPicMode = GRAY_IMAGE
    else:
        newPicMode = RGB_IMAGE
    print("got specs",newSpecs)

def python_fu_receiveosc_receiveImage(*msg):
    global pic, receiving
    print("receiving", msg[0][2], len(msg[0][3]))
    pic = pic + msg[0][3]

def python_fu_receiveosc_displayImage(*msg):
    global receiving
    print("displaying")
    receiving = 3

def python_fu_receiveosc( inImage, inDrawable, netAddr="127.0.0.1",
                       port=57130):
    global receiving,newSpecs,pic
    inImage.disable_undo()
    gimp.progress_init("receiving...")
    receiving = 1
    startingTime = time.time()
    # get right port for sc
    if shelf.has_key('oscnetaddr'):
        sendAddr = shelf['oscnetaddr'][0]
    else:
        sendAddr = "127.0.0.1"
    if shelf.has_key('oscport'):
        sendPort = shelf['oscport'][0]
    else:
        sendPort = 57120
    ## init osc listeners
    osc.init()
    osc.listen(netAddr, port)
    osc.bind(python_fu_receiveosc_storeSpecs, "/gimp/spec")
    osc.bind(python_fu_receiveosc_receiveImage, "/gimp/pic")
    osc.bind(python_fu_receiveosc_displayImage, "/gimp/end")
    ## ping sc to send image
    osc.sendMsg("/gimp/ping", [-1], sendAddr, sendPort)
    ## loop until done
    while receiving:
        #print("ping", len(pic))
        if receiving == 3:
            time.sleep(1)
            gimp.progress_update(96)
            newPic = []
            newLayer = gimp.Layer(inImage,
                                  "fromOSC",
                                  newSpecs[0],
                                  newSpecs[1],
                                  RGB_IMAGE, 100, NORMAL_MODE)
            inImage.add_layer(newLayer, 0)
            pdb.gimp_edit_fill(newLayer, BACKGROUND_FILL)
            newPic = newLayer.get_pixel_rgn(0,0,
                                            newSpecs[0],newSpecs[1], True)
            #newPic = pic
            print(len(pic))
            ## remove all brightness values
            ## convert from int to chr-values
            ## if newSpecs[2] == 4:
            ##     for index in range(len(pic)):
            ##         if index%4 == 3:
            ##             pic[index] = 255
            ##         elif index == 0:
            ##             picAsStr = chr(pic[index])
            ##         else:
            ##             picAsStr = picAsStr + chr(pic[index])
            ## set the pixel region to pic
            #print(pic)
            newPic[0:newSpecs[0],0:newSpecs[1]] = pic
            newLayer.flush()
            newLayer.update(0,0,newSpecs[0],newSpecs[1])
            print("flushed & updated")
            receiving = 0
        elif time.time() - startingTime > 20:
            print("time's up")
            receiving = 0
        else:
            gimp.progress_update(int(18 * (time.time() - startingTime)))
            #time.sleep(0.2)
    osc.dontListen()
    inImage.enable_undo()
    gimp.displays_flush()
    gimp.extension_ack()
    #gimp.delete(newLayer)


register(
    "python_fu_receiveosc",
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
        (PF_INT, "port", _("Port to listen to"), 57130),
        ],
    [],
    python_fu_receiveosc,
    menu="<Image>/Filters/Sound",
    domain=("gimp20-template", locale_directory) 
  )

main()
