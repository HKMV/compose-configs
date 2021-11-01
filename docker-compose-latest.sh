#!/bin/sh
#
# 在容器中运行 docker-compose 
#
# 此脚本将尝试通过将卷用于以下路径来镜像主机路径 :
#   * $(pwd)
#   * $(dirname $COMPOSE_FILE) if it's set
#   * $HOME if it's set
#
# 您可以使用 $COMPOSE_OPTIONS 环境变量添加额外的卷（或任何 docker run 选项）。
#


set -e

IMAGE="scjtqs/docker-compose:latest"


# 用于连接到 docker 主机的设置选项
if [ -z "$DOCKER_HOST" ]; then
    DOCKER_HOST="/var/run/docker.sock"
fi
if [ -S "$DOCKER_HOST" ]; then
    DOCKER_ADDR="-v $DOCKER_HOST:$DOCKER_HOST -e DOCKER_HOST"
else
    DOCKER_ADDR="-e DOCKER_HOST -e DOCKER_TLS_VERIFY -e DOCKER_CERT_PATH"
fi


# 为撰写配置和上下文设置卷挂载
if [ "$(pwd)" != '/' ]; then
    VOLUMES="-v $(pwd):$(pwd)"
fi
if [ -n "$COMPOSE_FILE" ]; then
    COMPOSE_OPTIONS="$COMPOSE_OPTIONS -e COMPOSE_FILE=$COMPOSE_FILE"
    compose_dir=$(realpath "$(dirname "$COMPOSE_FILE")")
fi
# TODO：还要检查 --file 参数
if [ -n "$compose_dir" ]; then
    VOLUMES="$VOLUMES -v $compose_dir:$compose_dir"
fi
if [ -n "$HOME" ]; then
    VOLUMES="$VOLUMES -v $HOME:$HOME -e HOME" # 传入 HOME 以共享 docker.config 并允许 ~/-relative 路径工作。
fi

# 如果我们检测到一个，只分配 tty 
if [ -t 0 ] && [ -t 1 ]; then
    DOCKER_RUN_OPTIONS="$DOCKER_RUN_OPTIONS -t"
fi

# 始终设置 -i 以支持 run/exec 中的管道和终端输入
DOCKER_RUN_OPTIONS="$DOCKER_RUN_OPTIONS -i"


# 处理用户安全 
if docker info --format '{{json .SecurityOptions}}' 2>/dev/null | grep -q 'name=userns'; then
    DOCKER_RUN_OPTIONS="$DOCKER_RUN_OPTIONS --userns=host"
fi

# shellcheck disable=SC2086
exec docker run --rm $DOCKER_RUN_OPTIONS $DOCKER_ADDR $COMPOSE_OPTIONS $VOLUMES -w "$(pwd)" $IMAGE "$@"
