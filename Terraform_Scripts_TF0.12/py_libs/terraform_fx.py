import subprocess

def create_verify(varfile=None):
    if varfile == None:
        subprocess.run('terraform init', shell=True)
        subprocess.run('terraform apply -auto-approve', shell=True, check=True, capture_output=True)
        subprocess.run('terraform plan', shell=True, check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    elif varfile:
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run('terraform init', shell=True)
        subprocess.run(['terraform', 'apply', var_arg, '-auto-approve'], check=True, capture_output=True)
        subprocess.run(['terraform', 'plan', var_arg], check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    else:
        raise Exception('Too many arguments: create_verify(). # of args: {}'.format(len(args)))


def import_test(resource, name, varfile=None):
    if varfile == None:
        resource_name = 'aviatrix_' + resource + '.' + name
        output_id = '"$(terraform output ' + name + '_id)"'
        subprocess.run(['terraform', 'state', 'rm', resource_name], check=True, capture_output=True)
        subprocess.run('terraform import ' + resource_name + ' ' + output_id, shell=True, check=True, capture_output=True)
        subprocess.run('terraform plan', shell=True, check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    elif varfile:
        resource_name = 'aviatrix_' + resource + '.' + name
        output_id = '"$(terraform output ' + name + '_id)"'
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'state', 'rm', resource_name], check=True, capture_output=True)
        subprocess.run('terraform import ' + var_arg + ' ' + resource_name + ' ' + output_id, shell=True, check=True, capture_output=True)
        subprocess.run(['terraform', 'plan', var_arg], check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    else:
        raise Exception('Too many arguments: import_test()')


def update_test(varfile, varfile2=None):
    if varfile2 == None:
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'apply', var_arg, '-auto-approve'], check=True, capture_output=True)
        subprocess.run(['terraform', 'plan', var_arg], check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    elif varfile2:
        var_arg = '-var-file=' + varfile + '.tfvars'
        var_arg2 = '-var-file=' + varfile2 + '.tfvars'
        subprocess.run(['terraform', 'apply', var_arg, var_arg2, '-auto-approve'], check=True, capture_output=True)
        subprocess.run(['terraform', 'plan', var_arg, var_arg2], check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    else:
        raise Exception('Too many arguments: update_test()')


def destroy_test(varfile=None):
    if varfile == None:
        subprocess.run('terraform destroy -auto-approve', shell=True, check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    elif varfile:
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'destroy', var_arg, '-auto-approve'], check=True, capture_output=True)
        subprocess.run('terraform show', shell=True)
    else:
        raise Exception('Too many arguments: destroy_test()')


def destroy_target(resource, name):
    target_arg = '-target=aviatrix_' + resource + '.' + name
    subprocess.run(['terraform', 'destroy', target_arg, '-auto-approve'], check=True, capture_output=True)
    subprocess.run('terraform show', shell=True)
