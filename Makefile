
.PHONY: plan
plan:
	terraform init
	terraform plan -refresh=false -out cloudtrail.plan
	terraform show -json cloudtrail.plan > cloudtrail.tfplan
