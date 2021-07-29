#!/bin/bash
action=$1
namespace=dev
#-----------------------------------------------------------

if [[ $action == "outage" ]]; then
  echo 'setting up temp/error page'
  kubectl delete ing -n $namespace sapience-ui
  kubectl apply -f ingress/static-page.yml -n $namespace
elif [[ $action == "nooutage" ]]; then
  echo 'Settiing up real page'
  kubectl delete ing -n $namespace sapience-ui
  kubectl apply -f ingress/sapience-ui.yml -n $namespace
fi