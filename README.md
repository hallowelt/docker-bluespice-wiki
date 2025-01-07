# BlueSpice MediaWiki

<img style="display:block;margin:auto" src="./root-fs/var/www/html/Bluespice_Icon.svg" width="100" height="100" alt="BlueSpice MediaWiki" />

## Build

```bash
docker build -t bluespice/wiki:latest .
```

## ENV vars

| Variable                     | Default Value  | Description                        | Optional |
|------------------------------|----------------|------------------------------------|----------|
| `CACHE_HOST`                 | `cache`        | Cache host                         | Yes      |
| `CACHE_PORT`                 | `11211`        | Cache port                         | Yes      |
| `DB_HOST`                    | `database`     | Database host                      | No       |
| `DB_NAME`                    | `bluespice`    | Database name                      | No       |
| `DB_PASS`                    | `null`         | Database password                  | No       |
| `DB_PREFIX`                  | `''`           | Database prefix                    | Yes      |
| `DB_ROOT_PASS`               | `null`         | Database root password             | Yes      |
| `DB_ROOT_USER`               | `root`         | Database root user                 | Yes      |
| `DB_TYPE`                    | `mysql`        | Database type                      | No       |
| `DB_USER`                    | `bluespice`    | Database user                      | No       |
| `DEV_WIKI_DEBUG`             | `null`         | Enable debug mode                  | Yes      |
| `DEV_WIKI_DEBUG_LOGCHANNELS` | `null`         | Debug log channels                 | Yes      |
| `EDITION`                    | `null`         | Edition of the wiki                | Yes      |
| `FORMULA_HOST`               | `formula`      | Formula host                       | Yes      |
| `FORMULA_PORT`               | `10044`        | Formula port                       | Yes      |
| `FORMULA_PROTOCOL`           | `http`         | Formula protocol                   | Yes      |
| `INTERNAL_WIKI_SECRETKEY`    | `null`         | Secret key for the wiki            | No       |
| `INTERNAL_WIKI_UPGRADEKEY`   | `null`         | Upgrade key for the wiki           | No       |
| `PDF_HOST`                   | `pdf`          | PDF host                           | Yes      |
| `PDF_PORT`                   | `8080`         | PDF port                           | Yes      |
| `PDF_PROTOCOL`               | `http`         | PDF protocol                       | Yes      |
| `SEARCH_HOST`                | `search`       | Search host                        | Yes      |
| `SEARCH_PORT`                | `9200`         | Search port                        | Yes      |
| `SEARCH_PROTOCOL`            | `http`         | Search protocol                    | Yes      |
| `SMTP_HOST`                  | `null`         | SMTP host                          | Yes      |
| `SMTP_IDHOST`                | `null`         | SMTP ID host                       | Yes      |
| `SMTP_PASS`                  | `null`         | SMTP password                      | Yes      |
| `SMTP_PORT`                  | `25`           | SMTP port                          | Yes      |
| `SMTP_USER`                  | `null`         | SMTP username                      | Yes      |
| `WIKI_EMERGENCYCONTACT`      | `''`           | Emergency contact email            | Yes      |
| `WIKI_HOST`                  | `localhost`    | Host for the wiki                  | No       |
| `WIKI_LANG`                  | `en`           | Language code for the wiki         | No       |
| `WIKI_NAME`                  | `BlueSpice`    | Name of the wiki                   | No       |
| `WIKI_PASSWORDSENDER`        | `''`           | Password sender email              | Yes      |
| `WIKI_PORT`                  | `443`          | Port for the wiki                  | No       |
| `WIKI_PROTOCOL`              | `https`        | Protocol for the wiki              | No       |

## Profiling

The image contains the Excimer profiler, which can be used in production scenarios. To enable it, set `_profiler=trace` or `_profiler=speedscope` in
- the query string (GET parameter) of the URL
- the POST body of the request
- a cookie

Results will be stored in `/data/bluespice/logs`. JSON files can be viewed with the [Speedscope](https://www.speedscope.app/) viewer. LOG files can be processed with https://github.com/brendangregg/FlameGraph

See https://www.mediawiki.org/wiki/Excimer and https://techblog.wikimedia.org/2021/03/03/profiling-php-in-production-at-scale for details.