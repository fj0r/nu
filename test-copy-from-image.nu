let CLEAN = false
let ctn = (buildah from ubuntu:jammy | str trim)
let ctn_dropbear = (buildah from fj0rd/scratch:dropbear | str trim)

echo $"setup target env"
buildah config --port 22 $ctn
buildah config --volume /world $ctn

{
    LANG:  C.UTF-8
    LC_ALL: C.UTF-8
    TIMEZONE: Asia/Shanghai
    XDG_CONFIG_HOME: /etc
    PYTHONUNBUFFERED: x
    NVIM_PRESET: full
} | transpose k v | each {|x|
    buildah config --env $"($x.k)=($x.v)" $ctn
}

echo $"copy dropbear"
buildah copy --from $ctn_dropbear $ctn / /

### commit
echo "commit"
buildah commit --format docker $ctn nu

echo "clean"
buildah rm $ctn_dropbear
buildah rm $ctn
