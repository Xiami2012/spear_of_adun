# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eapi7-ver systemd user

MY_PN="${PN%-bin}"
MY_P=${MY_PN}-${PV}

DESCRIPTION="Analytics and search dashboard for Elasticsearch"
HOMEPAGE="https://www.elastic.co/products/kibana"
SRC_URI="https://artifacts.elastic.co/downloads/${MY_PN}/${MY_P}-linux-x86_64.tar.gz"

# source: LICENSE.txt and NOTICE.txt
LICENSE="Apache-2.0 Artistic-2 BSD BSD-2 CC-BY-3.0 CC-BY-4.0 icu ISC MIT MPL-2.0 OFL-1.1 openssl public-domain Unlicense WTFPL-2 ZLIB"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="net-libs/nodejs"

S="${WORKDIR}/${MY_P}-linux-x86_64"

pkg_setup() {
	enewgroup kibana
	enewuser kibana -1 -1 /opt/${MY_PN} kibana
}

src_prepare() {
	default

	# remove bundled nodejs
	rm -r node || die

	# remove empty unused directory
	rmdir data || die
}

src_install() {
	insinto /etc/${MY_PN}
	doins -r config/.
	rm -r config || die

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/${MY_PN}.logrotate ${MY_PN}

	newconfd "${FILESDIR}"/${MY_PN}.confd ${MY_PN}
	newinitd "${FILESDIR}"/${MY_PN}.initd ${MY_PN}
	systemd_newunit "${FILESDIR}"/${MY_PN}.service-r1 ${MY_PN}.service

	insinto /opt/${MY_PN}
	doins -r .

	chmod +x "${ED%/}"/opt/${MY_PN}/bin/* || die

	diropts -m 0750 -o kibana -g kibana
	keepdir /var/log/${MY_PN}
}

pkg_postinst() {
	elog "This version of Kibana is compatible with Elasticsearch $(ver_cut 1-2)"
	elog
	elog "To set a customized Elasticsearch instance:"
	elog "  OpenRC: set ES_INSTANCE in /etc/conf.d/${MY_PN}"
	elog "  systemd: set elasticsearch.url in /etc/${MY_PN}/kibana.yml"
	elog
	elog "Elasticsearch can run local or remote."
}
