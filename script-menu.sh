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
    MENU_CMD="dmenu"
    MENU_ARGS=
else
    MENU_CMD="rofi"
    MENU_ARGS=('-dmenu')
fi

if [ $# -lt 2 ] || [ ! -d $1 ]; then
	ERROR_MSG="Invalid arguments passed to script-menu.sh!\n\nUsage:\nscript-menu.sh SCRIPT_PATH TERMINAL_EMULATOR_COMMAND\n\nExample:\nscript-menu.sh ~/scripts termite -e"

	if [ MENU_CMD == "rofi" ]; then
		rofi -e "${ERROR_MSG}"
	else
		printf "${ERROR_MSG}\n"
	fi

	exit
fi

SCRIPT_PATH=$(readlink -f "$1")
MENU_ARGS+=('-p' "${SCRIPT_PATH}"/)
EXECUTABLES=$(find "${SCRIPT_PATH}" -maxdepth 1 -executable -type f | sed "s:${SCRIPT_PATH}/::") 

SCRIPT_CHOICE="${SCRIPT_PATH}/"$(printf "${EXECUTABLES}" | ${MENU_CMD} "${MENU_ARGS[@]}")

if [ $? -ne 0 ]; then
	exit
fi

"${@:2}" "${SCRIPT_CHOICE}"

if [ $? -ne 0 ]; then
  ERROR_MSG="Could not execute ${@:2} ${SCRIPT_CHOICE}"

  if [ MENU_CMD == "rofi" ]; then
      rofi -e "${ERROR_MSG}"
  else
      printf "${ERROR_MSG}\n"
  fi
fi
