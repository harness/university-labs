deploy-infra:
	helm install prometheus kube-prometheus
	helm install loki grafana-loki
	helm install tempo grafana-tempo
	helm install grafana grafana
	helm ls

destroy-infra:
	helm uninstall grafana
	helm uninstall tempo
	helm uninstall loki
	helm uninstall prometheus
	helm ls
	