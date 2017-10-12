#!/bin/sh

user="";
pass="";
IS_VER=0;
IS_USER=0;
IS_PASS=0;
IS_LOGIN=0;
MAX_LIMIT=0;

COOKIE_FILE=".cookie_file.tmp"
VER_PIC="verCode.png"

Verification()
{
	rm -f $COOKIE_FILE $VER_PIC
	curl -S --cookie $COOKIE_FILE --cookie-jar $COOKIE_FILE https://portal.nctu.edu.tw/captcha/pic.php > /dev/null
	curl -S --cookie $COOKIE_FILE -o $VER_PIC https://portal.nctu.edu.tw/captcha/pitctest/pic.php  > /dev/null
	VER_CODE=`curl -X POST -F "image=@./$VER_PIC" https://nasa.cs.nctu.edu.tw/sap/2017/hw2/captcha-solver/api/`
	
	echo $VER_CODE | grep -q '[0-9][0-9][0-9][0-9]'
	if [ $? = 0 ]; then
		IS_VER=1
	else
		IS_VER=0
	fi
}
UserName()
{
	user=$(dialog \
		--title "學號" \
		--inputbox "請輸入學號:" 10 30 \
		3>&1 1>&2 2>&3 3>&- )
	
	if [ $? = 1 ]; then 
		clear
		exit
	fi
	
	echo $user | grep -q '[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
	if [ $? != 0 ]; then
		dialog --title "學號" --msgbox "學號錯誤，請重新輸入" 10 30
	else
		IS_USER=1
	fi
	clear
}
Password()
{
	pass=$(dialog \
		--insecure --title "密碼" \
		--passwordbox "請輸入單一登入系統的密碼:" 10 30 \
		3>&1 1>&2 2>&3 3>&- )\
		
	if [ $? = 1 ]; then 
		clear
		exit
	fi
	
	if [ "$pass" = "" ]; then
		dialog --title "密碼" --msgbox "密碼不能為空，請重新輸入" 10 30
	else
		IS_PASS=1
	fi
	
	clear
}
LoginFail()
{
	dialog --title "錯誤" --msgbox "帳號或是密碼輸入錯誤!請重新輸入" 10 30
	IS_VER=0
	IS_USER=0
	IS_PASS=0
}

while [ $IS_LOGIN = 0 ]
do
	while [ $IS_USER = 0 ]
	do
		UserName
	done

	while [ $IS_PASS = 0 ]
	do
		Password
	done

	while [ $IS_VER = 0 ]
	do
		Verification
	done
	
	IS_LOGIN=`curl -i https://portal.nctu.edu.tw/portal/chkpas.php? \
				--cookie $COOKIE_FILE \
				--data 'username='"${user}"'&password='"${pass}"'&seccode='"${VER_CODE}"'&pwdtype=static&Submit2=登入(Login)' \
				| grep 'HTTP/1.1' | awk '{if( $2 == "302" ){print "1"} else if( $2 == "200"){print "0"}}'`
	if [ $IS_LOGIN = 0 ]; then
		LoginFail
	fi
done		

formdata=`curl -S --cookie $COOKIE_FILE https://portal.nctu.edu.tw/portal/relay.php?D=cos | node extractFormdata.js`

curl -S "https://course.nctu.edu.tw/jwt.asp" \
	--cookie $COOKIE_FILE \
	--cookie-jar $COOKIE_FILE \
	--data $formdata > /dev/null
	

curl -i -S --cookie $COOKIE_FILE https://course.nctu.edu.tw/index.asp > /dev/null
curl -i -S --cookie $COOKIE_FILE https://course.nctu.edu.tw/adSchedule.asp | \
	iconv -f big5 -t utf-8 | grep -o "&nbsp\|^[^<].*<br>" | \
	awk '{sub(/.br./, "");sub(/&nbsp/,"."); print }' | \
	awk 'BEGIN{count=0; ORS=""; print "Mon.", "Tue.", "Wed.", "Thu.", "Fri.", "Sat.", "Sun.\n" } \
		{if(count % 7 == 0 && count != 0 ){ print "\n"} { print $1,"";count++}} \
		END{print "\n"}' | \
	column -t

