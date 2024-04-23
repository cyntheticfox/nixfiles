#!/usr/bin/env bash

# Input devices
REAL_MIC_IN="alsa_input.usb-Antlion_Audio_Antlion_USB_Microphone-00.mono-fallback"
REAL_LINE_IN="alsa_input.usb-ASUS_CU4K30_UVC_UHD_Video_902B001040901291-02.iec958-stereo"

# Virtual control devices
MIC_VIRT_DEV_IN="stream-mic"
LINE_VIRT_DEV_IN="stream-line-in"

# Output devices
REAL_HEADPHONES_OUT='alsa_output.usb-Generic_USB_Audio_200901010001-00.HiFi__hw_Dock__sink'
OUTPUT_DEV_OUT="discord-mic-out"

# Create virtual devices
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name="$MIC_VIRT_DEV_OUT" channel_map=front-left,front-right
pactl load-module module-null-sink media.class=Audio/Sink sink_name="$LINE_VIRT_DEV_OUT" channel_map=stereo

pw-link "$REAL_MIC_IN:capture_MONO" "$MIC_VIRT_DEV_OUT:input_FL"
pw-link "$REAL_MIC_IN:capture_MONO" "$MIC_VIRT_DEV_OUT:input_FR"
pw-link "$REAL_LINE_IN:capture_FL" "$LINE_VIRT_DEV_OUT:playback_FL"
pw-link "$REAL_LINE_IN:capture_FR" "$LINE_VIRT_DEV_OUT:playback_FR"

# Create output sink
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name="$OUTPUT_DEV" channel_map=front-left,front-right

pw-link "$MIC_VIRT_DEV_IN:capture_FL" "$OUTPUT_DEV_OUT:input_FL"
pw-link "$MIC_VIRT_DEV_IN:capture_FR" "$OUTPUT_DEV_OUT:input_FR"
pw-link "$LINE_VIRT_DEV_IN:monitor_FL" "$OUTPUT_DEV_OUT:input_FL"
pw-link "$LINE_VIRT_DEV_IN:monitor_FR" "$OUTPUT_DEV_OUT:input_FR"

# Link to headphones out
pw-link "$LINE_VIRT_DEV_IN:monitor_FL" "$REAL_HEADPHONES_OUT:playback_FL"
pw-link "$LINE_VIRT_DEV_IN:monitor_FR" "$REAL_HEADPHONES_OUT:playback_FR"
