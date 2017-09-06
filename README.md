Docker php-fpm
====

php-fpm用のDockerfile


## build

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