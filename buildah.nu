let CLEAN = false
let ctn = (buildah from ubuntu:jammy | str trim)
let ctn_dropbear = (buildah from fj0rd/scratch:dropbear | str trim)

echo $"setup target env"
buildah config --port 22 $ctn
buildah config --volume /world $ctn
buildah config --workingdir /world $ctn
buildah config --entrypoint /usr/local/bin/nu $ctn

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

def down-from-github [
    repo: string
    keyword: string
] {
    echo $"download: `($repo)`"
    fetch -H [Accept application/vnd.github.v3+json] $"https://api.github.com/repos/($repo)/releases"
    | where prerelease == false
    | get 0.assets
    | where name =~ $keyword
    | get 0.browser_download_url
    | fetch -r $in
}

### fetch nu

mkdir assets/bin

down-from-github nushell/nushell linux
| tar zxf - -C assets/bin --strip-components=2 --wildcards 'nu_*_linux/nushell-*/nu*'


### fetch rg

down-from-github BurntSushi/ripgrep x86_64-unknown-linux-musl
| tar zxf - -C assets/bin --strip-components=1 --wildcards 'ripgrep-*-x86_64-unknown-linux-musl/rg'

### fetch btm
down-from-github ClementTsang/bottom x86_64-unknown-linux-musl
| tar zxf - -C assets/bin btm

### install
buildah copy $ctn assets/bin /usr/local/bin

if $CLEAN { rm -rf assets/bin }

### setup nu
do {
    cd assets
    git clone --depth=1 git@github.com:fj0r/nushell.git
    buildah copy $ctn nushell /etc/nushell
}

### commit
echo "commit"
buildah commit --format docker $ctn nu

echo "clean"
buildah rm $ctn_dropbear
buildah rm $ctn
