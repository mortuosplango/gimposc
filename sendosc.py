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
                       bFlatten=False,
                       netAddr="127.0.0.1",
                       port=57120):
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

    ## start communication and send the specs of the picture
    osc.init()
    osc.sendMsg("/gimp/spec",
                [width, height, pr.bpp],
                netAddr, port)

    ## 
    prp = pr[0:width,0:height]
    pic = [ ]
    ## the message size is limited to 1024 integers
    ## therefore split the picture in separate messages
    for index in range(0,width*height*pr.bpp):
        if index%1024 == 1023:
            osc.sendMsg("/gimp", pic, netAddr, port)
            pic = [ ]
        ## convert the hex values into integers to not
        ## confuse the client with pseudo-unicodes
        pic.append(ord(prp[index]))
    osc.sendMsg("/gimp", pic, netAddr, port)

    ## end communication:
    osc.sendMsg("/gimp", [-1], netAddr, port)

    ## clean up if the image was flattened.
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
        (PF_BOOL, "bFlatten", "Flatten image?", False),
        (PF_STRING, "netAddr", _("IP-Address"), '127.0.0.1'),
        (PF_INT, "port", _("Port to send to"), 57120),
        ],
    [],
    python_fu_sendosc,
    menu="<Image>/Filters/Sound",
    domain=("gimp20-template", locale_directory) 
  )

main()