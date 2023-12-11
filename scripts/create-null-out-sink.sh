#!/usr/bin/env bash

# Input devices
REAL_MIC_L_IN="alsa_input.usb-Antlion_Audio_Antlion_USB_Microphone-00.mono-fallback:capture_MONO"
REAL_MIC_R_IN="alsa_input.usb-Antlion_Audio_Antlion_USB_Microphone-00.mono-fallback:capture_MONO"
REAL_LINE_L_IN="alsa_input.usb-ASUS_CU4K30_UVC_UHD_Video_902B001040901291-02.iec958-stereo:capture_FL"
REAL_LINE_R_IN="alsa_input.usb-ASUS_CU4K30_UVC_UHD_Video_902B001040901291-02.iec958-stereo:capture_FR"

# Virtual control devices
MIC_VIRT_DEV="stream-mic"
LINE_VIRT_DEV="stream-line-in"

# Output devices
OUTPUT_DEV="discord-mic-out"

# Create virual devices
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name="$MIC_VIRT_DEV" channel_map=front-left,front-right
pactl load-module module-null-sink media.class=Audio/Sink sink_name="$LINE_VIRT_DEV" channel_map=stereo

pw-link "$REAL_MIC_L_IN" "$MIC_VIRT_DEV:input_FL"
pw-link "$REAL_MIC_R_IN" "$MIC_VIRT_DEV:input_FR"
pw-link "$REAL_LINE_L_IN" "$LINE_VIRT_DEV:playback_FL"
pw-link "$REAL_LINE_R_IN" "$LINE_VIRT_DEV:playback_FR"

# Create output sink
pactl load-module module-null-sink media.class=Audio/Source/Virtual sink_name="$OUTPUT_DEV" channel_map=front-left,front-right

pw-link "$MIC_VIRT_DEV:capture_FL" "$OUTPUT_DEV:input_FL"
pw-link "$MIC_VIRT_DEV:capture_FR" "$OUTPUT_DEV:input_FR"
pw-link "$LINE_VIRT_DEV:monitor_FL" "$OUTPUT_DEV:input_FL"
pw-link "$LINE_VIRT_DEV:monitor_FR" "$OUTPUT_DEV:input_FR"
