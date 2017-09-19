#!/bin/bash
# vim: set expandtab ts=4 sw=4:

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

MENU_CMD="rofi"
MENU_ARGS=( -dmenu -width -168 )
CLIP_CMD="xclip"
CLIP_ARGS=( -selection clipboard )
XTERM_CMD="termite"
XTERM_ARGS=( --hold )

BASIC_UNIT_OPTS='clip\nedit\nstart\nstop\nenable\ndisable\nenable and start\nrestart'

filter_basic_opts(){
	case "$MENU_CHOICE" in
	"clip")
		printf "$SELECTED_UNIT" | "$CLIP_CMD" "${CLIP_ARGS[@]}"
		exit
		;;
	"edit")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl edit ${SELECTED_UNIT}"
		exit
        ;;
	"start")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl start ${SELECTED_UNIT}"
		exit
		;;
	"stop")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl stop ${SELECTED_UNIT}"
		exit
		;;
	"enable")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl enable${SELECTED_UNIT}"
		exit
		;;
	"disable")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl disable ${SELECTED_UNIT}"
		exit
		;;
	"enable and start")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl enable --now ${SELECTED_UNIT}"
		exit
		;;
	"restart")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl restart ${SELECTED_UNIT}"
		exit
		;;
	"mask")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl mask ${SELECTED_UNIT}"
		exit
		;;
	"unmask")
		$XTERM_CMD "${XTERM_ARGS[@]}" -e "sudo systemctl unmask ${SELECTED_UNIT}"
		exit
		;;
	"")
		exit ;;
    esac

	return
}

unit_menu(){
	UNIT_MENU_OPTS="$BASIC_UNIT_OPTS"

	MENU_CHOICE=$(printf "$UNIT_MENU_OPTS" | "$MENU_CMD" "${MENU_ARGS[@]}" -p "${SELECTED_UNIT}:")

	filter_basic_opts

	return
}

socket_menu(){
	SOCKET_MENU_OPTS="$BASIC_UNIT_OPTS"

	MENU_CHOICE=$(printf "$SOCKET_MENU_OPTS" | "$MENU_CMD" "${MENU_ARGS[@]}" -p "${SELECTED_UNIT}:")

	filter_basic_opts

	return
}

timer_menu(){
	TIMER_MENU_OPTS="$BASIC_UNIT_OPTS"

	MENU_CHOICE=$(printf "$TIMER_MENU_OPTS" | "$MENU_CMD" "${MENU_ARGS[@]}" -p "${SELECTED_UNIT}:")

	filter_basic_opts

	return
}

service_menu(){
	SERVICE_MENU_OPTS="$BASIC_UNIT_OPTS"

	MENU_CHOICE=$(printf "$SERVICE_MENU_OPTS" | "$MENU_CMD" "${MENU_ARGS[@]}" -p "${SELECTED_UNIT}:")

	filter_basic_opts

	return
}

list_unit_files_menu(){
	LIST_UNIT_FILES_MENU_OPTS="${BASIC_UNIT_OPTS}"

	MENU_CHOICE=$(printf "$LIST_UNIT_FILES_MENU_OPTS" | "$MENU_CMD" "${MENU_ARGS[@]}" -p "${SELECTED_UNIT}:")

	filter_basic_opts

	return
}

extract_systemctl(){
	SYSTEMD_OUTPUT=$(systemctl "${SYSTEMD_PARAMS[@]}")
	SYSTEMD_HEADER=$(echo "$SYSTEMD_OUTPUT" | head -n 1 | sed 's/[ \t]*$//')
	SYSTEMD_BODY=$(systemctl "${SYSTEMD_PARAMS[@]}" --no-legend)

	return
}

select_unit(){
	extract_systemctl

	SELECTED_UNIT=$(printf "${SYSTEMD_BODY}" | "$MENU_CMD" "${MENU_ARGS[@]}" -p "$MENU_MODE": -mesg "$SYSTEMD_HEADER" | "$UNIT_REGEX_CMD" "${UNIT_REGEX_ARGS[@]}")

	if [ -z $SELECTED_UNIT ]; then
		exit
	fi

	return
}

main_menu(){
	MAIN_MENU_OPTS='suspend\nhibernate\nhybrid-sleep\npoweroff\nreboot\nlist unit files\nunit\nsocket\ntimer\nservice\ntarget\ndevice\nmount\nautomount\nswap\npath\nslice\nscope'
	MENU_MODE=$(printf "$MAIN_MENU_OPTS" | "$MENU_CMD" "${MENU_ARGS[@]}" -p 'systemd:')

	case "$MENU_MODE" in
	"unit")
		SYSTEMD_PARAMS=( list-units )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		unit_menu
		;;
	"socket")
		SYSTEMD_PARAMS=( list-sockets )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $2}' )
		select_unit 
		socket_menu
		;;
	"timer")
		SYSTEMD_PARAMS=( list-timers )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $(NF-1)}' )
		select_unit 
		timer_menu
		;;
	"service")
		SYSTEMD_PARAMS=( list-units --type=service )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"target")
		SYSTEMD_PARAMS=( list-units --type=target )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"device")
		SYSTEMD_PARAMS=( list-units --type=device )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"mount")
		SYSTEMD_PARAMS=( list-units --type=mount )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"automount")
		SYSTEMD_PARAMS=( list-units --type=automount )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"swap")
		SYSTEMD_PARAMS=( list-units --type=swap )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"path")
		SYSTEMD_PARAMS=( list-units --type=path )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"slice")
		SYSTEMD_PARAMS=( list-units --type=slice )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"scope")
		SYSTEMD_PARAMS=( list-units --type=scope )
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit 
		service_menu
		;;
	"list unit files")
		SYSTEMD_PARAMS=("list-unit-files")
		UNIT_REGEX_CMD="awk"
		UNIT_REGEX_ARGS=( '{print $1}' )
		select_unit
		list_unit_files_menu
		;;
	"poweroff")
		systemctl poweroff
		exit
		;;
	"reboot")
		systemctl reboot
		exit
		;;
	"suspend")
		systemctl suspend
		exit
		;;
	"hibernate")
		systemctl hibernate
		exit
		;;
	"hybrid-sleep")
		systemctl hybrid-sleep
		exit
		;;
	esac

	return
}

main_menu
