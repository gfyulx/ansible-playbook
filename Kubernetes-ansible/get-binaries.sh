#!/bin/bash
:  ${KUBE_VERSION:=1.13.5} ${CNI_VERSION:=v0.7.5} ${ETCD_version:=3.2.24} ${FLANNEL_version:=0.11.0}
:  ${CNI_URL:=https://github.com/containernetworking/plugins/releases/download}

function down_kube(){
    docker pull registry.cn-hangzhou.aliyuncs.com/gfyulx/kubernetes:$KUBE_VERSION
    docker run --rm -d --name temp registry.cn-hangzhou.aliyuncs.com/gfyulx/kubernetes:$KUBE_VERSION sleep 10
    docker cp temp:/kubernetes-server-linux-amd64.tar.gz .
    tar -zxvf kubernetes-server-linux-amd64.tar.gz  --strip-components=3 -C /usr/local/bin kubernetes/server/bin/kube{let,ctl,-apiserver,-controller-manager,-scheduler,-proxy}
}

function down_etcd(){
#    docker pull quay.io/coreos/etcd:$ETCD_version
    docker pull registry.cn-hangzhou.aliyuncs.com/gfyulx/etcd:$ETCD_version
    docker tag registry.cn-hangzhou.aliyuncs.com/gfyulx/etcd:$ETCD_version quay.io/coreos/etcd:$ETCD_version
    docker rmi registry.cn-hangzhou.aliyuncs.com/gfyulx/etcd:$ETCD_version
    docker run --rm -d --name temp quay.io/coreos/etcd:$ETCD_version sleep 10
    docker cp temp:/usr/local/bin/etcd /usr/local/bin
    docker cp temp:/usr/local/bin/etcdctl /usr/local/bin
}

function down_flanneld(){
# https://github.com/coreos/flannel/releases

#    [ ! -f "flannel-${FLANNEL_version}-linux-amd64.tar.gz" ] && \
#        wget https://github.com/coreos/flannel/releases/download/${FLANNEL_version}/flannel-${FLANNEL_version}-linux-amd64.tar.gz
#    [ ! -f /usr/local/bin/flanneld ] && tar -zxvf flannel-${FLANNEL_version}-linux-amd64.tar.gz -C /usr/local/bin flanneld
    docker pull registry.cn-hangzhou.aliyuncs.com/gfyulx/flannel:${FLANNEL_version}
    docker run --rm -d --name flanneld registry.cn-hangzhou.aliyuncs.com/gfyulx/flannel:${FLANNEL_version} sleep 10
    docker cp flanneld:/opt/bin/flanneld /usr/local/bin/

}

function down_cni(){
    [ ! -f cni-plugins-amd64-${CNI_VERSION}.tgz ] && \
    wget "${CNI_URL}/${CNI_VERSION}/cni-plugins-amd64-${CNI_VERSION}.tgz" 
}

function down_base(){
    down_kube
    down_etcd
}

if [ "${#@}" -eq 1 ];then
    if [ "$1" != 'all' ];then
        down_$1
    else
        down_kube
        down_etcd
        down_cni
        down_flanneld
    fi
fi

