pkgname=ekeymgr
pkgver=1.0.0
pkgrel=1
pkgdesc="Entry management system using NFC tag"
url="https://github.com/ray45422/ekeymgr"
license=('MIT')
depends=('libphobos')
makedepends=('ldc' 'dub' 'git')
arch=('any')

source=('git+https://github.com/ray45422/ekeymgr.git')
md5sums=('SKIP')
srcdir="source"

build(){
	cd ${srcdir}/${pkgname}
	dub build --build=release --compiler=ldc --parallel
}

package(){
	install -d "$pkgdir"/usr/bin
	install -m755 ${srcdir}/${pkgname}/${pkgname} "$pkgdir"/usr/bin/
	install -d "$pkgdir"/etc/ekeymgr
	install -m644 ${srcdir}/${pkgname}/${pkgname}.conf "$pkgdir"/etc/ekeymgr/
}
