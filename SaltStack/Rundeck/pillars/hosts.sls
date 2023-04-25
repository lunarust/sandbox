application_hosts:
  staging1:
      - staging1-app01.plop.local
      - staging1-app02.plop.local
  dev1:
      - dev1-app01.plop.local
  prod1:
      - prod1-app01.plop.local
      - prod1-app02.plop.local
      - prod1-app03.plop.local
      - prod1-app04.plop.local

parallel_nodes:
  - prod1-app01.plop.local
  - prod1-app03.plop.local

cache_nodes:
  - staging1-app01.plop.local
  - prod1-app01.plop.local
  - prod1-app03.plop.local

cluster_microservices_nodes:
    staging:
      - staging1-microservice01.plop.local
      - staging1-microservice02.plop.local
    prod:
      - prod1-microservice01.plop.local
      - prod1-microservice02.plop.local

management_hosts:
   - rundeck.plop.local
   - automation.plop.local
   - monitoring.plop.local

rundeck_env:
  - DEV1
  - STAGING1
  - PROD1

microservices_list:
  - ms1
  - ms2
  - ms3
