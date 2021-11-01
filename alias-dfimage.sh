#!/bin/sh
# shopt -s expand_aliases
# if [ `grep -c "dfimage" ~/.bash_profile` -eq '0' ]; then
#     echo 'alias dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"' >> ~/.bash_profile
# fi
# source ~/.bash_profile

# export dfimage="docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage"


if [[ ! -f /usr/local/bin/dfimage ]]; then
    echo '#!/bin/sh' >> /usr/local/bin/dfimage
    echo 'docker run -v /var/run/docker.sock:/var/run/docker.sock --rm alpine/dfimage $@' >> /usr/local/bin/dfimage
    chmod +x /usr/local/bin/dfimage
fi
echo "用法: dfimage 镜像名称"