registry_mirrors = registry.cn-chengdu.aliyuncs.com
username = youyin319
namespace = eininst
group = g

project = qy

build:
ifeq (${f},)
	docker build -f Dockerfile --build-arg APP=${app} -t ${project}-${app} .
else
	docker build -f ${f} --build-arg APP=${app} -t ${project}-${app} .
endif



build-nginx:
	docker build -f nginx/Dockerfile -t nginx .

run-nginx:
	docker run -it --rm -v $(CURDIR)/nginx:/etc/nginx \
	-v $(CURDIR)/nginx/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
	-v /etc/trojan-go/privkey.pem:/etc/nginx/conf.d/ssl/privkey.pem \
	-v /etc/trojan-go/fullchain.pem:/etc/nginx/conf.d/ssl/fullchain.pem \
	--net=host -p 80:80 -p 443:443 nginx

flush:
	docker run --rm -v $(CURDIR)/requirements.txt:/app/requirements.txt \
	qy:latest bash -c "pip freeze > requirements.txt"


clean:
	yes | docker system prune

.PHONY: build flush api