Docker php-fpm
====

php-fpm用のDockerfile



## build & up

```
sh docker-compose.sh
```



## compose down

```
sh docker-compose.sh down
```



## 主なミドルウェア

- php-fpm 7.1.8
  - OPcache
- Xdebug 2.5.4
- PHPUnit 6.3.0
- PHP_CodeSniffer 3.0.2
- Phing 2.16.0
- PHPMD 1.5.0
- phpcpd 3.0.0
- phpDox 0.9.0
- PDepend 2.5.0
- phploc 4.0.0
- mecab 0.996
- aws-cli 1.11.146
- composer 1.5.1
- git 2.1.4




## 本コンテナのphp設定を変更する場合

```docker-compose.yml
version: '2'
services:
  php:
    image: hyyyyde/php-fpm:1.0.0
    volumes:
      - nginx/20-hosts.conf:/etc/nginx/conf.d/20-hosts.conf
```

※上記の例では、ローカルに配置してある20-hosts.confをコンテナ内の20-hosts.confを上書きしています



### listenを変更する際の注意点

`www.conf` を以下のようにマウントしてください

```
volumes:
  - ./php-fpm/www.conf:/usr/local/etc/php-fpm.d/zz-www.conf
```

※ローカルにある `www.conf` を `zz-www.conf` にマウントしている。　　

`zz-www.conf` としているのは、php-fpmの公式コンテナイメージ内に  
`/usr/local/etc/php-fpm.d/zz-docker.conf` があり、この中で、

```zz-docker.conf
[www]
listen = [::]:9000
```

とlistenを握りつぶしているため、 `zz-www.conf` でさらに上書きする必要があるためです。