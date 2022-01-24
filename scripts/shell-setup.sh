#!/bin/bash
set -e

mkdir -p /nonexistent
mount -t tmpfs tmpfs /nonexistent
usermod -d /nonexistent nobody >/dev/null
cd /nonexistent
mkdir .kube

cat <<EOF > .kube/config
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    server: "https://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT}"
    insecure-skip-tls-verify: true
  name: "Default"
contexts:
- context:
    cluster: "Default"
    user: "Default"
  name: "Default"
current-context: "Default"
users:
- name: "Default"
  user:
    token: "${TOKEN}"
EOF

kubectl completion bash > .kube/completion.bash.inc

cat >> .bash_profile <<EOF
PS1="\w > "
EOF

printf '
# Kubectl shell completion
source /etc/profile.d/bash_completion.sh
source $HOME/.kube/completion.bash.inc
' >> .bash_profile

cat >> .bashrc <<EOF
PS1="\w > "
EOF

printf '
# Kubectl shell completion
source /etc/profile.d/bash_completion.sh
source $HOME/.kube/completion.bash.inc
' >> .bashrc

chmod 777 .kube
chmod 666 .kube/config
exec su - -s /bin/bash nobody