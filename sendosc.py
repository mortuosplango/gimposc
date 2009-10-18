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
                       bFlatten=True,
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
        bpp = pr.bpp
    else:
        pr = inDrawable.get_pixel_rgn(0,0,width,height,False)
        if ((pr.bpp == 4) | (pr.bpp == 1)) :
            bpp = pr.bpp
        elif (pr.bpp == 2):
            bpp = 1
        elif (pr.bpp == 3):
            bpp = 4

    bpp = 4
    ## start communication and send the specs of the picture
    osc.init()
    osc.sendMsg("/gimp/spec",
                [width, height, bpp],
                netAddr, port)

    prp = pr[0:width,0:height]
    pic = [ ]
    prpindex = 0
    ## the message size is limited to 1024 integers
    ## therefore split the image in separate messages
    for index in range(bpp * width * height):
        if index%1024 == 0:
            osc.sendMsg("/gimp", pic[-1024:], netAddr, port)
            if index%2048 == 0:
                del pic[:1024]
        ## strip the alpha channel
        if  (index%4 == 0) and (index > 0):
            ## if it is RGB, calc the brightness and save it:
            ##         0,299 * R + 0,587 * G + 0,114 * B
            pic.append(
                round(
                    (pic[-3] * 0.299)
                    + (pic[-2] * 0.587)
                    + (pic[-1] * 0.114)))
            #if bpp == pr.bpp:
            #    prpindex += 1
        ## convert the hex values into integers to not
        ## confuse the client with pseudo-unicodes
                #pic.append(ord(prp[prpindex]))
        else:
            pic.append(ord(prp[prpindex]))
            prpindex = prpindex + 1
            
    ## send the remainder
    
    osc.sendMsg("/gimp", pic[-((width*height*bpp)%1024):], netAddr, port)
    ## end communication:
    osc.sendMsg("/gimp", [-1], netAddr, port)
    ## clean up
    del pic
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
