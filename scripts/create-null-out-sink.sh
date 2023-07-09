#!/usr/bin/env bash

pactl load-module module-null-sink media.class=Audio/Sink sink_name=combined-sink channel_map=stereo
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name=virtualmic channel_map=front-left,front-right

pw-link alsa_input.usb-ASUS_CU4K30_UVC_UHD_Video_902B001040901291-02.iec958-stereo:capture_FL combined-sink:playback_FL
pw-link alsa_input.usb-ASUS_CU4K30_UVC_UHD_Video_902B001040901291-02.iec958-stereo:capture_FR combined-sink:playback_FR
pw-link alsa_input.usb-Antlion_Audio_Antlion_USB_Microphone-00.mono-fallback:capture_MONO combined-sink:playback_FL
pw-link alsa_input.usb-Antlion_Audio_Antlion_USB_Microphone-00.mono-fallback:capture_MONO combined-sink:playback_FR

pw-link combined-sink:monitor_FL virtualmic:input_FL
pw-link combined-sink:monitor_FR virtualmic:input_FR
