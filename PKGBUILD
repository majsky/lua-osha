_gitname=lua-osha
pkgname=('osha')
pkgrel=1
arch=('any')
pkgdesc='Factorio headless server autoupdater'
url='https://github.com/majsky/lua-osha'
license=('DWYW')
depends=('lua' 'lua-http' 'lua-argparse' 'wget' 'tmux')
makedepends=('luarocks' 'lua' 'git')
source=("${_gitname}::git+${url}.git")
sha256sums=(SKIP)

pkgver() {
  cd ${_gitname}
  printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

build() {
    cd ${_gitname}

    luarocks make --pack-binary-rock --lua-version=5.4 --deps-mode=none osha-scm-1.rockspec
}

package() {
	cd ${_gitname}

  luarocks install --lua-version=5.4 --tree="$pkgdir/usr/" --deps-mode=none --no-manifest osha-scm-1.all.rock

	install -Dm644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
  
	install -Dm755 launcher.sh "$pkgdir/usr/bin/osha"

}