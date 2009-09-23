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

# i18n
#
import gettext
locale_directory = gimp.locale_directory
gettext.install( "gimp20-template" , locale_directory, unicode=True )

#         
sendosc_help = _("Send image as OSC-Message.")                                
sendosc_description = _("Print Console")+" "+sendosc_help

def python_fu_printc( inImage, inDrawable, netAddr="127.0.0.1",
                       port=57120):
    width = inDrawable.width
    height = inDrawable.height

    inImage = gimp.Image(width, height, RGB)
    inImage.disable_undo()
    #osc.init()
##    inImage.flatten()



    pr = inDrawable.get_pixel_rgn(0,0,width,height,False,False)
    prp = pr[0:width,0:height]

    #osc.sendMsg("/gimp/spec", [width, pr.bpp], netAddr, port)


    pic = []

    ## the message size is limited
    ## therefore split the picture in seperate messages at the limit
    ## TODO: what is the origin of that limit? 6574
    # range * 2 for greyscale
    for index in range(0,width*height*pr.bpp):
        ## convert the hex values into integers to not
        ## confuse sclang etc. with pseudo-unicodes
        pic.append(ord(prp[index]))
    #osc.sendMsg("/gimp", pic, netAddr, port)
    print "pic ", pic, " end"

    ## end communication:
    #osc.sendMsg("/gimp", [-1], netAddr, port)
    #osc.dontListen()

    gimp.delete(inImage)


register(
    "python_fu_printc",
    sendosc_description,
    sendosc_help,
    "Holger Ballweg",
    "GPL License",
    "2009",
    _("PrintC"),
    "RGB*,GRAY*",
    [
        (PF_IMAGE, "inImage", "Input image", None),
        (PF_DRAWABLE, "inLayer", "Input drawable", None),
        (PF_STRING, "netAddr", _("IP-Address"), '127.0.0.1'),
        (PF_INT, "port", _("Port to send to"), 57120),
        ],
    [],
    python_fu_printc,
    menu="<Image>/Filters/Sound",
    domain=("gimp20-template", locale_directory) 
  )

main()
