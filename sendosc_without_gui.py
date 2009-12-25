#!/usr/bin/env python

from gimpfu import *
from gimpshelf import shelf

# i18n
#
import gettext
locale_directory = gimp.locale_directory
gettext.install( "gimp20-template" , locale_directory, unicode=True )

sendosc_help = _("Send image as OSC-Message.")
sendosc_description = _("SendOSC (without GUI")+" "+sendosc_help

def python_fu_sendosc_headless( inImage, inDrawable):
    addr = "127.0.0.1"
    port = 57120
    bFlatten = False
    # just call sendosc with the saved parameters
    # if there are any
    if shelf.has_key('oscnetaddr'):
        addr = shelf['oscnetaddr'][0]
    if shelf.has_key('oscport'):
        port = shelf['oscport'][0]
    if shelf.has_key('oscbflatten'):
        bFlatten = shelf['oscbflatten'][0]
    
    pdb.python_fu_sendosc(inImage,inDrawable,bFlatten,addr,port)

    gimp.delete(inImage)


register(
    "python_fu_sendosc_headless",
    sendosc_description,
    sendosc_help,
    "Holger Ballweg",
    "GPL License",
    "2009",
    _("SendOSC (without GUI)"),
    "RGB*,GRAY*",
    [
        (PF_IMAGE, "inImage", "Input image", None),
        (PF_DRAWABLE, "inLayer", "Input drawable", None),
        ],
    [],
    python_fu_sendosc_headless,
    menu="<Image>/Filters/Sound",
    domain=("gimp20-template", locale_directory) 
  )

main()
