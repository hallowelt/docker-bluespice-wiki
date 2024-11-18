# BlueSpice MediaWiki

<img style="display:block;margin:auto" src="./root-fs/var/www/html/Bluespice_Icon.svg" width="100" height="100" alt="BlueSpice MediaWiki" />

## Build

```bash
docker build -t bluespice/wiki:latest .
```

## DEV build

```bash
docker build --build-arg dev=1 -t bluespice/wiki:dev .
```