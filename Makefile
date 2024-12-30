install:
	sh $(CURDIR)/scripts/install.sh ${host}

start:
	caddy start
	systemctl start trojan-go

trojan-start:
	systemctl start trojan-go

trojan-stop:
	systemctl stop trojan-go

trojan-log:
	journalctl -u trojan-go -f

trojan-dev:
	/etc/trojan-go/trojan-go -config ${CURDIR}/configs/$(MY_DOMAIN).json

caddy-log:
	journalctl -u caddy -f

clean:
	yes | docker system prune

.PHONY: install start trojan-start trojan-stop trojan-log trojan-dev clean