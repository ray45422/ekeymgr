pkgname=ekeymgr
pkgver=1.0.0
pkgrel=1
pkgdesc="Entry management system using NFC tag"
url="https://github.com/ray45422/ekeymgr"
license=('MIT')
depends=('liblphobos' 'libmariadbclient')
makedepends=('ldc' 'dub' 'git')
arch=('any')

source=('git+https://github.com/ray45422/ekeymgr.git')
md5sums=('SKIP')

build(){
	cd ${srcdir}/${pkgname}
	dub build --build=release --compiler=ldc --parallel
}

package(){
	install -d "$pkgdir"/usr/bin
	install -m755 ${srcdir}/${pkgname}/${pkgname} "$pkgdir"/usr/bin/
	install -d "$pkgdir"/etc/ekeymgr
	install -m644 ${srcdir}/${pkgname}/${pkgname}.conf "$pkgdir"/etc/ekeymgr/
	install -d "$pkgdir"/usr/share/webapps/ekeymgr
	install -m755 -t "$pkgdir"/usr/share/webapps/ekeymgr/ ${srcdir}/${pkgname}/http/*.*
	install -d "$pkgdir"/usr/share/webapps/ekeymgr/php
	install -m755 -t "$pkgdir"/usr/share/webapps/ekeymgr/php/ ${srcdir}/${pkgname}/http/php/*.*
	install -d "$pkgdir"/usr/share/webapps/ekeymgr/resources
	install -m755 -t "$pkgdir"/usr/share/webapps/ekeymgr/resources/ ${srcdir}/${pkgname}/http/resources/*.*
}
