iamlive --set-ini --mode proxy --output-file ../plan.json --refresh-rate 1 --sort-alphabetical --bind-addr 127.0.0.1:10080 --ca-bundle ~/.iamlive/ca.pem --ca-key ~/.iamlive/ca.key

# export HTTP_PROXY=http://127.0.0.1:10080
# export HTTPS_PROXY=http://127.0.0.1:10080
# export AWS_CA_BUNDLE=~/.iamlive/ca.pem

# terraform plan -var-file __variables/pipeline.tfvars

# lsof -i:10080
# kill -9 <<process>>