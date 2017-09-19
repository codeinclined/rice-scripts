#!/bin/sh

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
    MENU_CMD="dmenu"
    MENU_ARGS=
else
    MENU_CMD="rofi"
    MENU_ARGS=(-dmenu -i -width -80 -p kak-session: -mesg $'SESSION\t\t\t\t\tUSER')
fi

SESSION_LIST=

for KAK_USER in $(ls -1 /tmp/kakoune); do
    for KAK_USER_SESSION in $(ls -1 /tmp/kakoune/"${KAK_USER}"); do
        SESSION_LIST="${SESSION_LIST}${KAK_USER_SESSION}\t\t\t\t\t${KAK_USER}\n"
    done
done

SESSION_LIST="${SESSION_LIST}"'(New session...)'

MENU_INPUT=$(printf "${SESSION_LIST}" | "$MENU_CMD" "${MENU_ARGS[@]}")

if [ $? -eq 0 ]; then
    if [ "$MENU_INPUT" == '(New session...)' ]; then
        SESSION_CHOICE=$(${MENU_CMD} ${MENU_ARGS[@]})
	if [ $? -eq 0 ]; then
            kak -s "${SESSION_CHOICE}"
        fi
    else
        SESSION_CHOICE=$(printf "${MENU_INPUT}" | awk '{print $1}')
        SESSION_USER=$(printf "${MENU_INPUT}" | awk '{print $(NF)}') 
        kak -c "${SESSION_USER}/${SESSION_CHOICE}" $@
    fi
fi
