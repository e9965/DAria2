#!/bin/bash
IFS=$(echo -ne "\n\b")
export DOWNFILE=${3}
rm -rf ${DOWNFILE}.aria2
#-------------------------------------------------------------------
#<程序基本運行函數>
INI_MKDIR(){
	if [[ ! -d $1 ]]
	then
		mkdir -p $1
	fi
}
SET_BASIC_ENV_VAR(){
	export UNZIP_THREAD=5
	export APP_BIN=${SHELL_BOX_PATH}/bin/
	export PATH=${PATH}:${APP_BIN}
	export SHELL_BIN=${SHELL_BOX_PATH}/bin/sh/
	export PASSWD_FILE=${SHELL_BOX_PATH}/conf/passwd.conf
	export SUB_PASSWD_FILE=/kaggle/working/passwd.conf
	#For Kaggle
	export TEMP_PATH=${SHELL_BOX_PATH}/temp
	export TEMP_UNZIP_PATH=${SHELL_BOX_PATH}/temp/unzip/
	export INPUT_DIR=${TEMP_UNZIP_PATH}
	export RCLONE="${SHELL_BOX_PATH}/conf/rclone.conf"
	INI_MKDIR ${SHELL_BIN%\/*}
	INI_MKDIR ${TEMP_UNZIP_PATH}
	chmod -R a+rwx ${SHELL_BOX_PATH}
	[[ -f ${SUB_PASSWD_FILE} ]] && export PASSWD=($(cat ${PASSWD_FILE}) $(cat ${SUB_PASSWD_FILE})) || export PASSWD=($(cat ${PASSWD_FILE}))
}
VIDEO_DOWNLOAD_CHECK(){
	if [[ ${DOWNFILE##*.} =~ "m3u8" ]]
	then
		return 0
	else
		return 2
	fi
}
SLICE_CHECK(){
	if [[ -n $(echo ${DOWNFILE} | grep -oE "\.part[[:digit:]]+\.rar" | grep -vE "\.part1\.rar") ]] || [[ -n $(echo ${DOWNFILE} | grep -oE "\.z[[:digit:]]+") ]] || [[ -n $(echo ${DOWNFILE} | grep -oE "\.7z\.[[:digit:]]+" | grep -Ev "\.7z\.001") ]]
	then
		return 0
	else
		return 2
	fi
}
Clean_Log() {
    [[ ! -e ${1} ]] && echo -e "Aria2 日志文件不存在 !" && exit 1
    echo >${1}
}
#-------------------------------------------------------------------
#<Main_Program_Body>
#<程序運行-环境参数>
	SHELL_BOX_PATH=$(readlink -f ${0})
	export SHELL_BOX_PATH=${SHELL_BOX_PATH%\/*}
	SET_BASIC_ENV_VAR
	SLICE_CHECK && exit 0
#-----------------------------------------------------------------------
	VIDEO_DOWNLOAD_CHECK && source ${SHELL_BIN}m3u8_rc.sh || source ${SHELL_BIN}auto_unzip.sh
#-----------------------------------------------------------------------
Clean_Log "/root/.aria2c/aria2.log"
IFS=$OLD_IFS
exit 0