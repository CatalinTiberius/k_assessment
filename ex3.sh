# I could use the output from Grype as my example. If I need to extract only the names and 
# the severity, I would use awk, and I could also filter the results by critical severity using grep

cat ex3_text.txt | awk '{print $1, $6}' | grep 'critical'

# Results: github.com/cosmos/ibc-go/v7 Critical

kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml