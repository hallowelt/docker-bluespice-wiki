# BlueSpice MediaWiki

<img style="display:block;margin:auto" src="./root-fs/var/www/html/Bluespice_Icon.svg" width="100" height="100" alt="BlueSpice MediaWiki" />

## Build

```bash
docker build -t bluespice/wiki:latest .
```

## ENV vars

| Variable                     | Default Value  | Description                                          | Optional |
|------------------------------|----------------|------------------------------------------------------|----------|
| `AV_HOST`                    | `antivirus`    | Hostname of a `clamav` compatible service            | Yes      |
| `AV_PORT`                    | `3310`         | Port of a `clamav` compatible service                | Yes      |
| `CACHE_HOST`                 | `cache`        | Hostname of a `bluespice/cache` compatible service   | Yes      |
| `CACHE_PORT`                 | `11211`        | Port of a `bluespice/cache` compatible service       | Yes      |
| `DB_HOST`                    | `database`     | Database host                                        | Yes      |
| `DB_NAME`                    | `bluespice`    | Database name                                        | Yes      |
| `DB_NAME_PREFIX`             | `wiki_`        | Database name prefix for wiki farm instances         | Yes      |
| `DB_PASS`                    | `null`         | Database password                                    | No       |
| `DB_PREFIX`                  | `''`           | Database prefix                                      | Yes      |
| `DB_ROOT_PASS`               | `$DB_PASS`     | Database root password *)                            | No       |
| `DB_ROOT_USER`               | `$DB_USER`     | Database root user                                   | Yes      |
| `DB_TYPE`                    | `mysql`        | Database type                                        | Yes      |
| `DB_USER`                    | `bluespice`    | Database user                                        | Yes      |
| `DEV_WIKI_DEBUG`             | `null`         | Enable debug mode                                    | Yes      |
| `DEV_WIKI_DEBUG_LOGCHANNELS` | `null`         | Debug log channels, comma separated                  | Yes      |
| `DIAGRAM_HOST`               | `$WIKI_HOST`   | Hostname of a `bluespice/diagram` compatible service | Yes      |
| `DIAGRAM_PATH`               | `/_diagram/`   | Path of a `bluespice/diagram` compatible service     | Yes      |
| `DIAGRAM_PORT`               | `$WIKI_PORT`   | Port of a `bluespice/diagram` compatible service     | Yes      |
| `DIAGRAM_PROTOCOL`           | `$WIKI_PROTOCOL`| Protocol of a `bluespice/diagram` compatible service| Yes      |
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
| `SEARCH_PASS`                | ``             | Password of a `bluespice/search` compatible service  | Yes      |
| `SEARCH_PORT`                | `9200`         | Port of a `bluespice/search` compatible service      | Yes      |
| `SEARCH_PROTOCOL`            | `http`         | Protocol of a `bluespice/search` compatible service  | Yes      |
| `SEARCH_USER`                | ``             | User of a `bluespice/search` compatible service      | Yes      |
| `SMTP_HOST`                  | `null`         | SMTP host                                            | Yes      |
| `SMTP_IDHOST`                | `null`         | SMTP ID host                                         | Yes      |
| `SMTP_PASS`                  | `null`         | SMTP password                                        | Yes      |
| `SMTP_PORT`                  | `25`           | SMTP port                                            | Yes      |
| `SMTP_USER`                  | `null`         | SMTP username                                        | Yes      |
| `WIKI_EMERGENCYCONTACT`      | `''`           | Emergency contact email                              | No       |
| `WIKI_HOST`                  | `localhost`    | Host for the wiki                                    | Yes      |
| `WIKI_INITIAL_ADMIN_PASS`    | `null`         | Initial admin password. Uses random, if not set      | Yes      |
| `WIKI_INITIAL_ADMIN_USER`    | `Admin`        | Admin user name use during initial installation      | Yes      |
| `WIKI_LANG`                  | `en`           | Language code for the wiki                           | Yes      |
| `WIKI_NAME`                  | `BlueSpice`    | Name of the wiki                                     | Yes      |
| `WIKI_PASSWORDSENDER`        | `''`           | Password sender email                                | No       |
| `WIKI_PORT`                  | `443`          | Port for the wiki                                    | Yes      |
| `WIKI_PROTOCOL`              | `https`        | Protocol for the wiki                                | Yes      |
| `WIKI_SUBSCRIPTION_KEY`      | `null`         | Only used by PRO edition. Overrides in-app config    | Yes      |

*) See section "Database requirements for FARM edition"

## Directories and Volumes

The main directory for application data is `/data/`. The setup routine will create the following directories:

```
.
├── bluespice
│   ├── extensions
│   │   └── BlueSpiceFoundation
│   ├── farm-archive
│   ├── farm-instances
│   ├── images
│   ├── logs
│   │   ├── postupdate
│   │   └── baseversion
│   │
│   ├── oauth_private.key
│   ├── oauth_public.key
│   │
│   ├── post-init-settings.php
│   └── pre-init-settings.php
│
├── simplesamlphp
│   ├── cache
│   ├── certs
│   │   ├── saml.crt
│   │   └── saml.pem
│   ├── data
│   ├── logs
│   └── saml_idp_metadata.xml
|
├── adminPassword
└── .wikienv
```

If the application needs to connect to external services that use self-signed certificates, you need to add the certificate to the trusted certificates.
For this purpose, you can mount a volume to `/usr/local/share/ca-certificates/ca.crt`

## Profiling

The image contains the Excimer profiler, which can be used in production scenarios. To enable it, set `_profiler=trace` or `_profiler=speedscope` in
- the query string (GET parameter) of the URL
- the POST body of the request
- a cookie

Results will be stored in `/data/bluespice/logs`. JSON files can be viewed with the [Speedscope](https://www.speedscope.app/) viewer. LOG files can be processed with https://github.com/brendangregg/FlameGraph

See https://www.mediawiki.org/wiki/Excimer and https://techblog.wikimedia.org/2021/03/03/profiling-php-in-production-at-scale for details.

## Database requirements for FARM edition

If `DB_USER` is not allowed to create databases and the database with `DB_NAME` does not exist yet, you need to provide a `DB_ROOT_USER` and `DB_ROOT_PASS` during installation. In addition, the `FARM` edition will need to have a user that is allowed to create databases with the `DB_NAME_PREFIX` as prefix. This user can be the same as `DB_USER` or a different one. If you want to use a different user, you need to provide the `DB_ROOT_USER` and `DB_ROOT_PASS` during installation.