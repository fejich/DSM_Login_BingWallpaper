#user 输入自己的用户名，用于设置替换桌面壁纸与保存下来的文件权限
#user="fejich"

#如需设置用户桌面壁纸为每日美图去掉下面 wallpaper 注释，然后随意指定一张图片为壁纸
#wallpaper="/usr/syno/etc/preference/$user/wallpaper"

#如需收集每日美图去掉下面 savepath 注释并设置保存文件夹路径
#savepath="/volume1/photo/bing美图/"

#以下内容无需修改
pic=$(wget -t 5 --no-check-certificate -qO- "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1")
echo $pic|grep -q enddate||exit
link=$(echo https://www.bing.com$(echo $pic|sed 's/.\+"url"[:" ]\+//g'|sed 's/".\+//g'))
date=$(echo $pic|sed 's/.\+enddate[": ]\+//g'|grep -Eo 2[0-9]{7}|head -1)
tmpfile=/tmp/$date"_bing.jpg"
wget -t 5 --no-check-certificate $link -qO $tmpfile
[ -s $tmpfile ]||exit
rm -rf /usr/syno/etc/login_background*.jpg
cp -f $tmpfile /usr/syno/etc/login_background.jpg &>/dev/null
cp -f $tmpfile /usr/syno/etc/login_background_hd.jpg &>/dev/null
title=$(echo $pic|sed 's/.\+"title":"//g'|sed 's/".\+//g')
copyright=$(echo $pic|sed 's/.\+"copyright[:" ]\+//g'|sed 's/".\+//g')
word=$(echo $copyright|sed 's/(.\+//g')
if [ ! -n "$title" ];then
cninfo=$(echo $copyright|sed 's/，/"/g'|sed 's/,/"/g'|sed 's/(/"/g'|sed 's/ //g'|sed 's/\//_/g'|sed 's/)//g')
title=$(echo $cninfo|cut -d'"' -f1)
word=$(echo $cninfo|cut -d'"' -f2)
fi
sed -i s/login_background_customize=.*//g /etc/synoinfo.conf
echo "login_background_customize=\"yes\"">>/etc/synoinfo.conf
sed -i s/login_welcome_title=.*//g /etc/synoinfo.conf
echo "login_welcome_title=\"$title\"">>/etc/synoinfo.conf
sed -i s/login_welcome_msg=.*//g /etc/synoinfo.conf
echo "login_welcome_msg=\"$word\"">>/etc/synoinfo.conf
#替换桌面壁纸
if (echo $wallpaper|grep -q '/') then
cp -f $tmpfile $wallpaper
fi
#复制图片到保存文件夹
if (echo $savepath|grep -q '/') then
cp -f $tmpfile $savepath/$date@$title-$word.jpg
#修改图片的权限
chown $user:users $savepath/$date@$title-$word.jpg
#为保存的图片建立索引
synoindex -a $savepath/$date@$title-$word.jpg
fi
rm -rf /tmp/*_bing.jpg
