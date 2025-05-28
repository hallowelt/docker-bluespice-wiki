# BlueSpice MediaWiki

<img style="display:block;margin:auto" src="./root-fs/var/www/html/Bluespice_Icon.svg" width="100" height="100" alt="BlueSpice MediaWiki" />

## Build

```bash
docker build -t bluespice/wiki:latest .
```
## Warning
This image is not intended for production use! It serves as a stepping stone for upgrading from older versions.
To access the Wiki, go directly to /w (e.g. https://wiki.company.local/w), as the redirects are not working.

## ENV vars

| Variable                     | Default Value  | Description                                          | Optional |
|------------------------------|----------------|------------------------------------------------------|----------|
| `CACHE_HOST`                 | `cache`        | Hostname of a `bluespice/cache` compatible service   | Yes      |
| `CACHE_PORT`                 | `11211`        | Port of a `bluespice/cache` compatible service       | Yes      |
| `DB_HOST`                    | `database`     | Database host                                        | Yes      |
| `DB_NAME`                    | `bluespice`    | Database name                                        | Yes      |
| `DB_PASS`                    | `null`         | Database password                                    | No       |
| `DB_PREFIX`                  | `''`           | Database prefix                                      | Yes      |
| `DB_ROOT_PASS`               | `null`         | Database root password                               | Yes      |
| `DB_ROOT_USER`               | `root`         | Database root user                                   | Yes      |
| `DB_TYPE`                    | `mysql`        | Database type                                        | Yes      |
| `DB_USER`                    | `bluespice`    | Database user                                        | Yes      |
| `DEV_WIKI_DEBUG`             | `null`         | Enable debug mode                                    | Yes      |
| `DEV_WIKI_DEBUG_LOGCHANNELS` | `null`         | Debug log channels, comma separated                  | Yes      |
| `EDITION`                    | `null`         | Edition of the wiki                                  | Yes      |
| `FORMULA_HOST`               | `formula`      | Hostname of a `bluespice/formula` compatible service | Yes      |
| `FORMULA_PORT`               | `10044`        | Port of a `bluespice/formula` compatible service     | Yes      |
| `FORMULA_PROTOCOL`           | `http`         | Protocol of a `bluespice/formula` compatible service | Yes      |
| `INTERNAL_WIKI_SECRETKEY`    | `null`         | Secret key for the wiki                              | No       |
| `INTERNAL_WIKI_UPGRADEKEY`   | `null`         | Upgrade key for the wiki                             | No       |
| `PDF_HOST`                   | `pdf`          | Hostname of a `bluespice/pdf` compatible service     | Yes      |
| `PDF_PORT`                   | `8080`         | Port of a `bluespice/pdf` compatible service         | Yes      |
| `PDF_PROTOCOL`               | `http`         | Protocol of a `bluespice/pdf` compatible service     | Yes      |
| `SEARCH_HOST`                | `search`       | Hostname of a `bluespice/search` compatible service  | Yes      |
| `SEARCH_PORT`                | `9200`         | Port of a `bluespice/search` compatible service      | Yes      |
| `SEARCH_PROTOCOL`            | `http`         | Protocol of a `bluespice/search` compatible service  | Yes      |
| `SMTP_HOST`                  | `null`         | SMTP host                                            | Yes      |
| `SMTP_IDHOST`                | `null`         | SMTP ID host                                         | Yes      |
| `SMTP_PASS`                  | `null`         | SMTP password                                        | Yes      |
| `SMTP_PORT`                  | `25`           | SMTP port                                            | Yes      |
| `SMTP_USER`                  | `null`         | SMTP username                                        | Yes      |
| `WIKI_EMERGENCYCONTACT`      | `''`           | Emergency contact email                              | No       |
| `WIKI_HOST`                  | `localhost`    | Host for the wiki                                    | Yes      |
| `WIKI_LANG`                  | `en`           | Language code for the wiki                           | Yes      |
| `WIKI_NAME`                  | `BlueSpice`    | Name of the wiki                                     | Yes      |
| `WIKI_PASSWORDSENDER`        | `''`           | Password sender email                                | No       |
| `WIKI_PORT`                  | `443`          | Port for the wiki                                    | Yes      |
| `WIKI_PROTOCOL`              | `https`        | Protocol for the wiki                                | Yes      |

## Profiling

The image contains the Excimer profiler, which can be used in production scenarios. To enable it, set `_profiler=trace` or `_profiler=speedscope` in
- the query string (GET parameter) of the URL
- the POST body of the request
- a cookie

Results will be stored in `/data/bluespice/logs`. JSON files can be viewed with the [Speedscope](https://www.speedscope.app/) viewer. LOG files can be processed with https://github.com/brendangregg/FlameGraph

See https://www.mediawiki.org/wiki/Excimer and https://techblog.wikimedia.org/2021/03/03/profiling-php-in-production-at-scale for details.
