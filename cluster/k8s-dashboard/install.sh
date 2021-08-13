kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.3.1/aio/deploy/recommended.yaml
kubectl apply -f users
echo -e "\n\n"
echo "Kubernetes dashboard is installed, it should be accessible by doing the following:"
echo "1.) run kubectl proxy"
echo "2.) navigate to http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/ in your browser"
echo "3.) Use the following token to login"
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
