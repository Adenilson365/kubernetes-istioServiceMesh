#!/bin/bash

gcloud container clusters get-credentials devops-labs01 \
    --region=us-east1

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)

# Install nginx ingress controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0-beta.0/deploy/static/provider/cloud/deploy.yaml

#Install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.16.2/cert-manager.yaml


#Aplicando configurações iniciais

kubectl apply -f ./configs/namespace.yaml

kubectl apply -f ./configs/istio-gke-config.yaml

kubectl apply -f ./configs/

#Installing istio-base
helm install istio-base istio/base -n istio-system --wait

#Installing istiod
helm install istiod istio/istiod --namespace istio-system --set profile=ambient --wait

#install istio-cni
helm install istio-cni istio/cni -n istio-system --set profile=ambient --wait

#install istio-ztunnel
helm install ztunnel istio/ztunnel -n istio-system --wait

#Install kiali
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/kiali.yaml

#Install grafana
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/grafana.yaml

#Install prometheus
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.24/samples/addons/prometheus.yaml

#Install stack prometheus-grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack --version 67.5.0 --namespace obs -f ./obs/prom-values.yaml --wait

#Criar cluster issuer
kubectl apply -f ./configs/cluster-issuer.yaml

#Implantar aplicação
kubectl apply -f ./deploys/
