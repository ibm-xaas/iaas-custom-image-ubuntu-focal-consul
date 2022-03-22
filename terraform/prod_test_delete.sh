#!/usr/bin/env bash
# ./prod_test.sh | tee prod_test.log
#
#IBM_PROD_REGION=('us-south' 'us-east' 'au-syd' 'br-sao' 'ca-tor' 'eu-de' 'eu-gb' 'jp-osa')
#IBM_PROD_REGION=('us-south' 'us-east')
IBM_PROD_REGION=('us-south')

for region in "${IBM_PROD_REGION[@]}"
do
	echo $region
	terragrunt workspace select $region -no-color
	terragrunt destroy -no-color -auto-approve -var-file="${region}.tfvars"
done

terragrunt workspace select default -no-color

for region in "${IBM_PROD_REGION[@]}"
do
	echo $region
	terragrunt workspace delete $region -no-color
	rm ${region}.tfvars
done
