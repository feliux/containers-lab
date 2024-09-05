echo "Renaming keystore"
cp keystore/kafka.keystore.jks keystore/kafka-controller-0.keystore.jks
cp keystore/kafka.keystore.jks keystore/kafka-broker-0.keystore.jks

echo "Creating k8s secrets"
kubectl --kubeconfig ../kubeconfig.yaml create secret generic jks-secrets --from-file=kafka.truststore.jks=./truststore/kafka.truststore.jks --from-file=kafka.keystore.jks=./keystore/kafka.keystore.jks
# kubectl --kubeconfig ../kubeconfig.yaml create secret generic SECRET_NAME_0 --from-file=kafka.truststore.jks=./truststore/kafka.truststore.jks --from-file=kafka-controller-0.keystore.jks=./keystore/kafka-controller-0.keystore.jks --from-file=kafka-broker-0.keystore.jks=./keystore/kafka-broker-0.keystore.jks
# kubectl --kubeconfig ../kubeconfig.yaml create secret generic SECRET_NAME_1 --from-file=kafka.truststore.jks=./truststore/kafka.truststore.jks --from-file=kafka-controller-1.keystore.jks=./keystore/kafka-controller-0.keystore.jks --from-file=kafka-broker-1.keystore.jks=./keystore/kafka-broker-0.keystore.jks
# kubectl --kubeconfig ../kubeconfig.yaml create secret generic SECRET_NAME_2 --from-file=kafka.truststore.jks=./truststore/kafka.truststore.jks --from-file=kafka-controller-2.keystore.jks=./keystore/kafka-controller-0.keystore.jks --from-file=kafka-broker-2.keystore.jks=./keystore/kafka-broker-0.keystore.jks

echo "JKS to PEM"

echo "Server truststore"
keytool -importkeystore -srckeystore ./truststore/kafka.truststore.jks -destkeystore ./truststore/server.p12 -deststoretype PKCS12
openssl pkcs12 -in ./truststore/server.p12 -nokeys -out ./truststore/server.cer.pem

echo "Client keystore"
keytool -importkeystore -srckeystore ./keystore/kafka.keystore.jks -destkeystore ./keystore/client.p12 -deststoretype PKCS12
openssl pkcs12 -in ./keystore/client.p12 -nokeys -out ./keystore/client.cer.pem
openssl pkcs12 -in ./keystore/client.p12 -nodes -nocerts -out ./keystore/client.key.pem
