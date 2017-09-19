#!/bin/bash

################################################################################
# Copyright 2017 Joshua Taylor <taylor.joshua88@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################

rofi -version &> /dev/null

if [ $? -ne 0 ]; then
	echo "This script depends on rofi. Please install rofi and try again."
	exit
fi

CLIP_CMD="xclip"
CLIP_ARGS=(-selection clipboard)

CHARACTER_OPTIONS=

LEADING_BYTE=$(rofi -dmenu -p "unicode: 0x" -width -90 -mesg "Please enter the leading unicode byte. Blank is equivalent to 00.")

if [ $? -ne 0 ]; then
	exit
fi

STARTING_INDEX=0

if [ -z $LEADING_BYTE ] || [ $LEADING_BYTE == "00" ]; then
	LEADING_BYTE="00"
	CHARACTER_OPTIONS="0000\t\t<NUL>\n0001\t\t<SOH>\n0002\t\t<STX>\n0003\t\t<ETX>\n0004\t\t<EOT>\n0005\t\t<ENQ>\n0006\t\t<ACK>\n0007\t\t<BEL>\n0008\t\t<BS>\n0009\t\t<TAB>\n000a\t\t<LF>\n000b\t\t<VT>\n000c\t\t<FF>\n000d\t\t<CR>\n000e\t\t<SO>\n000f\t\t<SI>\n0010\t\t<DLE>\n0011\t\t<DC1>\n0012\t\t<DC2>\n0013\t\t<DC3>\n0014\t\t<DC4>\n0015\t\t<NAK>\n0016\t\t<SYN>\n0017\t\t<ETB>\n0018\t\t<CAN>\n0019\t\t<EM>\n001a\t\t<SUB>\n001b\t\t<ESC>\n001c\t\t<FS>\n001d\t\t<GS>\n001e\t\t<RS>\n001f\t\t<US>\n0020\n"
	STARTING_INDEX=33
fi

for ((i=STARTING_INDEX;i<256;i++)); do
	WORD_HEX="${LEADING_BYTE}$(printf '%02x' $i)"
	CHARACTER_OPTIONS="${CHARACTER_OPTIONS}${WORD_HEX}\t\t"$(printf "\u${WORD_HEX}" | sed 's/%/%%/' | sed 's/\\/\\\\/')'\n'
done

CHARACTER_CHOICE=$(printf "${CHARACTER_OPTIONS}" | rofi -dmenu -i -p "unicode: 0x${LEADING_BYTE} " -width -90 -mesg "Please enter the ending byte of the unicode sequence in hex." | awk '{print $1}')

printf '\u'"${CHARACTER_CHOICE}" | ${CLIP_CMD} "${CLIP_ARGS[@]}" &> /dev/null
