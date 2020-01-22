import os
import sys

def create_verify(varfile=None):
    try:
        if varfile == None:
            os.system('terraform init')
            os.system('terraform apply -auto-approve')
            os.system('terraform plan')
            os.system('terraform show')
        elif varfile:
            os.system('terraform init')
            os.system('terraform apply -var-file=' + varfile + '.tfvars -auto-approve')
            os.system('terraform plan -var-file=' + varfile + '.tfvars')
            os.system('terraform show')
        else:
            raise Exception('Too many arguments: create_verify(). # of args: {}'.format(len(args)))
    except:
        sys.exit()


def import_test(resource, name, varfile=None):
    try:
        if varfile == None:
            os.system('terraform state rm aviatrix_' + resource + '.' + name)
            os.system('terraform import aviatrix_' + resource + '.' + name + ' "$(terraform output ' + name + '_id)"')
            os.system('terraform plan')
            os.system('terraform show')
        elif varfile:
            os.system('terraform state rm aviatrix_' + resource + '.' + name)
            os.system('terraform import aviatrix_' + resource + '.' + name + ' "$(terraform output ' + name + '_id)"')
            os.system('terraform plan -var-file=' + varfile + '.tfvars')
            os.system('terraform show')
        else:
            raise Exception('Too many arguments: import_test()')
    except:
        sys.exit()


def update_test(varfile):
    try:
        os.system('terraform apply -var-file=' + varfile + '.tfvars -auto-approve')
        os.system('terraform plan -var-file=' + varfile + '.tfvars')
        os.system('terraform show')
    except:
        sys.exit()


def destroy_test(varfile=None):
    try:
        if varfile == None:
            os.system('terraform destroy -auto-approve')
            os.system('terraform show')
        elif varfile:
            os.system('terraform destroy -var-file=' + varfile + '.tfvars -auto-approve')
            os.system('terraform show')
        else:
            raise Exception('Too many arguments: destroy_test()')
    except:
        sys.exit()


def destroy_target(resource, name):
    try:
        os.system('terraform destroy -target=aviatrix_' + resource + '.' + name + ' -auto-approve')
        os.system('terraform show')
    except:
        sys.exit()
