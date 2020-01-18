import os

def create_verify(varfile=None):
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


def import_test(resource, name, varfile=None):
    if varfile == None:
        os.system('terraform state rm aviatrix_' + resource + '.' + name)
        os.system('terraform import aviatrix_' + resource '.' + name + ' "$(terraform output ' + name + '_id)"')
        os.system('terraform plan')
        os.system('terraform show')
    elif varfile:
        os.system('terraform state rm aviatrix_' + resource + '.' + name)
        os.system('terraform import aviatrix_' + resource '.' + name + ' "$(terraform output ' + name + '_id)"')
        os.system('terraform plan -var-file=' + varfile + '.tfvars')
        os.system('terraform show')
    else:
        raise Exception('Too many arguments: import_test()')


def update_test(varfile):
    os.system('terraform apply -var-file=' + varfile + '.tfvars -auto-approve')
    os.system('terraform plan -var-file=' + varfile + '.tfvars')
    os.system('terraform show')


def destroy_test(varfile=None):
    if varfile == None:
        os.system('terraform destroy -auto-approve')
        os.system('terraform show')
    elif varfile:
        os.system('terraform destroy -var-file=provider' + varfile + '.tfvars -auto-approve')
        os.system('terraform show')
    else:
        raise Exception('Too many arguments: destroy_test()')


def destroy_target(resource, name):
    os.system('terraform destroy -target=aviatrix_' + resource + '.' + name + ' -auto-approve')
    os.system('terraform show')
