
SHELL := /bin/bash
CFN_STACK_NAME=terraform-backend
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r .Account)

apply:
	aws cloudformation deploy \
	    --no-fail-on-empty-changeset \
	    --stack-name "$(CFN_STACK_NAME)" \
	    --template-file backend.yml

destroy:
	aws cloudformation delete-stack \
	    --stack-name "$(CFN_STACK_NAME)"

describe:
	aws cloudformation describe-stacks \
	    --stack-name "$(CFN_STACK_NAME)"

# generates a backend stub. run in this dir then copy elsewhere
backend:
	aws cloudformation describe-stacks \
	    --stack-name "$(CFN_STACK_NAME)" > describe-stacks.json
	echo bucket = `cat describe-stacks.json| jq '.Stacks[0].Outputs[] | select(.OutputKey=="bucket") | .OutputValue'` > backend.auto.tfvars
	echo dynamodb_table = `cat describe-stacks.json| jq '.Stacks[0].Outputs[] | select(.OutputKey=="dynamodbtable") | .OutputValue'` >> backend.auto.tfvars
	echo region = `cat describe-stacks.json| jq '.Stacks[0].Outputs[] | select(.OutputKey=="region") | .OutputValue'` >> backend.auto.tfvars
	rm describe-stacks.json
