#!/usr/bin/env bash

set -e

NAMESPACE="$1"
PATTERN="$2"

if [[ -z "$NAMESPACE" || -z "$PATTERN" ]]; then
  echo "Usage: $0 <namespace> <pod-name-pattern>"
  exit 1
fi

# Get matching pods
PODS=($(kubectl get pods --namespace "$NAMESPACE" --no-headers | awk -v pattern="$PATTERN" '$1 ~ pattern {print $1}'))

if [[ ${#PODS[@]} -eq 0 ]]; then
  echo "No pods matching '$PATTERN' found in namespace '$NAMESPACE'"
  exit 1
fi

# If more than one pod, let the user choose
if [[ ${#PODS[@]} -gt 1 ]]; then
  echo "Multiple pods found matching '$PATTERN':"
  select POD in "${PODS[@]}"; do
    if [[ -n "$POD" ]]; then
      break
    else
      echo "Invalid selection. Try again."
    fi
  done
else
  POD="${PODS[0]}"
fi

echo "Launching terminal for $POD in namespace: $NAMESPACE"
kubectl exec -it -n "$NAMESPACE" "$POD" -- /cnb/lifecycle/launcher bash
