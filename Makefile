install:
	.$(CURDIR)/install.sh ${host}

caddy:
	caddy start

trojan:
	systemctl start trojan-go

trojan-stop:
	systemctl stop trojan-go

log:
	journalctl -u trojan-go -f
dev:
	/etc/trojan-go/trojan-go -config ${CURDIR}/{host}.json

clean:
	yes | docker system prune

.PHONY: install caddy trojan trojan-stop clean