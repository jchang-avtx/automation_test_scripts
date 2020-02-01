import os
import sys
import subprocess

def create_verify(varfile=None):
    try:
        if varfile == None:
            subprocess.run('terraform init', shell=True)
            subprocess.run('terraform apply -auto-approve', shell=True, check=True)
            subprocess.run('terraform plan', shell=True, check=True)
            subprocess.run('terraform show', shell=True)
        elif varfile:
            var_arg = '-var-file=' + varfile + '.tfvars'
            subprocess.run('terraform init', shell=True)
            subprocess.run(['terraform', 'apply', var_arg, '-auto-approve'], check=True)
            subprocess.run(['terraform', 'plan', var_arg], check=True)
            subprocess.run('terraform show', shell=True)
        else:
            raise Exception('Too many arguments: create_verify(). # of args: {}'.format(len(args)))
    except:
        sys.exit()


def import_test(resource, name, varfile=None):
    try:
        if varfile == None:
            resource_name = 'aviatrix_' + resource + '.' + name
            output_id = '"$(terraform output ' + name + '_id)"'
            subprocess.run(['terraform', 'state', 'rm', resource_name], check=True)
            subprocess.run('terraform import ' + resource_name + ' ' + output_id, shell=True, check=True)
            subprocess.run('terraform plan', shell=True, check=True)
            subprocess.run('terraform show', shell=True)
        elif varfile:
            resource_name = 'aviatrix_' + resource + '.' + name
            output_id = '"$(terraform output ' + name + '_id)"'
            var_arg = '-var-file=' + varfile + '.tfvars'
            subprocess.run(['terraform', 'state', 'rm', resource_name], check=True)
            subprocess.run('terraform import ' + var_arg + ' ' + resource_name + ' ' + output_id, shell=True, check=True)
            subprocess.run(['terraform', 'plan', var_arg], check=True)
            subprocess.run('terraform show', shell=True)
        else:
            raise Exception('Too many arguments: import_test()')
    except:
        sys.exit()


def update_test(varfile):
    try:
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'apply', var_arg, '-auto-approve'], check=True)
        subprocess.run(['terraform', 'plan', var_arg], check=True)
        subprocess.run('terraform show', shell=True)
    except:
        sys.exit()


def destroy_test(varfile=None):
    try:
        if varfile == None:
            subprocess.run('terraform destroy -auto-approve', shell=True)
            subprocess.run('terraform show', shell=True)
        elif varfile:
            var_arg = '-var-file=' + varfile + '.tfvars'
            subprocess.run(['terraform', 'destroy', var_arg, '-auto-approve'], check=True)
            subprocess.run('terraform show', shell=True)
        else:
            raise Exception('Too many arguments: destroy_test()')
    except:
        sys.exit()


def destroy_target(resource, name):
    try:
        target_arg = '-target=aviatrix_' + resource + '.' + name
        subprocess.checkoutput(['terraform', 'destroy', target_arg, '-auto-approve'])
        subprocess.run('terraform show', shell=True)
    except:
        sys.exit()
