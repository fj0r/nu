let ctn = (buildah from nu | str trim)
# let mountpoint = (buildah mount $ctn)

def run [cmds] {
    for c in $cmds {
        buildah run $ctn $c        
    }
}

buildah config --env DEBIAN_FRONTEND=noninteractive $ctn

run [
    [ apt-get update ]
    [ apt-get upgrade -y ]
    [ apt-get install -y --no-install-recommends buildah skopeo ]
    [ apt-get autoremove -y ]
    [ apt-get clean -y ]
    [ rm -rf '/var/lib/apt/lists/*' ]
]

buildah commit --format docker $ctn nu:buildah
