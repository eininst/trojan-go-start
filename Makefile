install:
	.$(CURDIR)/install.sh ${host}

caddy:
	caddy start

caddy-log:
	journalctl -u trojan-go -f

caddy-dev:
	caddy run

trojan:
	systemctl start trojan-go

trojan-stop:
	systemctl stop trojan-go

trojan-log:
	journalctl -u trojan-go -f

trojan-dev:
	/etc/trojan-go/trojan-go -config ${CURDIR}/$(MY_DOMAIN).json

clean:
	yes | docker system prune

.PHONY: install caddy trojan trojan-stop clean