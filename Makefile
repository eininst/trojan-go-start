install:
	.$(CURDIR)/install.sh ${host}

caddy:
	caddy start

trojan:
	systemctl start trojan-go

trojan-stop:
	systemctl stop trojan-go

clean:
	yes | docker system prune

.PHONY: install caddy trojan trojan-stop clean