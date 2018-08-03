 Stuff in infrastructure.yml

The file provided by A&E is called `infrastructure.yml` and is loaded
by Ettin by default. Your app may well be counting on some of those
values to be defined in dev/test as well, so here's a sample

```yaml
base_dir: "/hydra-dev/dromedary-staging"
bind: "tcp://127.0.0.1:30800"
redis: {}
db:
  adapter: mysql2
  username: drmdry-xxxxx
  password: xxxxx
  host: db-dromedary-staging
  port: 3306
  database: dromedary-staging
  url: mysql2://drmdry-stgng:xxxxx
  
relative_url_root: "/m/middle-english-dictionary"
solr:
  url: "http://localhost:8081/solr/dromedary_staging"
```

