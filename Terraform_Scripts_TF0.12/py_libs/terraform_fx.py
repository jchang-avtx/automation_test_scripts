import subprocess

def create_verify(varfile=None, timeout=None, varval=None):
    if (varfile == None) and (varval == None):
        subprocess.run('terraform init', shell=True)
        subprocess.run('terraform apply -auto-approve', shell=True, check=True, capture_output=True, timeout=timeout)
        subprocess.run('terraform plan -detailed-exitcode', shell=True, check=True, capture_output=True)
    elif (varfile) and (varval == None):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run('terraform init', shell=True)
        subprocess.run(['terraform', 'apply', var_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
        subprocess.run(['terraform', 'plan', var_arg, '-detailed-exitcode'], check=True, capture_output=True)
    elif (varfile == None) and (varval):
        subprocess.run('terraform init', shell=True)
        subprocess.run(['terraform', 'apply', '-var', varval, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
        subprocess.run(['terraform', 'plan', '-var', varval, '-detailed-exitcode'], check=True, capture_output=True)
    elif (varfile) and (varval):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run('terraform init', shell=True)
        subprocess.run(['terraform', 'apply', var_arg, '-var', varval, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
        subprocess.run(['terraform', 'plan', var_arg, '-var', varval, '-detailed-exitcode'], check=True, capture_output=True)
    else:
        raise Exception('Too many arguments: create_verify(). # of args: {}'.format(len(args)))

    subprocess.run('terraform show', shell=True, check=True, capture_output=True)


def import_test(resource, name, varfile=None, varval=None):
    resource_name = 'aviatrix_' + resource + '.' + name
    output_id = '"$(terraform output ' + name + '_id)"'

    # Add [] check for resources with count index where outputID will not match resource ID -
    # Added in R2.16.3+ / U6.1-patch
    # eg. terraform import aviatrix_gateway.gateway[0] gw-name
    if "[" in name:
        new_name = name.split("[")[0]
        output_id = '"$(terraform output ' + new_name + '_id)"'

    if (varfile == None) and (varval == None):
        subprocess.run(['terraform', 'state', 'rm', resource_name], check=True, capture_output=True)
        subprocess.run('terraform import ' + resource_name + ' ' + output_id, shell=True, check=True, capture_output=True)
        subprocess.run('terraform plan', shell=True, check=True)
    elif (varfile) and (varval == None):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'state', 'rm', resource_name], check=True, capture_output=True)
        subprocess.run('terraform import ' + var_arg + ' ' + resource_name + ' ' + output_id, shell=True, check=True, capture_output=True)
        subprocess.run(['terraform', 'plan', var_arg], check=True)
    elif (varfile == None) and (varval):
        subprocess.run(['terraform', 'state', 'rm', resource_name], check=True, capture_output=True)
        subprocess.run('terraform import -var ' + varval + ' ' + resource_name + ' ' + output_id, shell=True, check=True, capture_output=True)
        subprocess.run(['terraform', 'plan', '-var', varval], check=True)
    elif (varfile) and (varval):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'state', 'rm', resource_name], check=True, capture_output=True)
        subprocess.run('terraform import ' + var_arg + ' ' + '-var ' + varval + ' ' + resource_name + ' ' + output_id, shell=True, check=True, capture_output=True)
        subprocess.run(['terraform', 'plan', var_arg, '-var', varval], check=True)
    else:
        raise Exception('Too many arguments: import_test()')

    subprocess.run('terraform show', shell=True, check=True, capture_output=True)


def update_test(varfile, varfile2=None, timeout=None):
    var_arg = '-var-file=' + varfile + '.tfvars'
    if varfile2 == None:
        subprocess.run(['terraform', 'apply', var_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
        subprocess.run(['terraform', 'plan', var_arg, '-detailed-exitcode'], check=True, capture_output=True)
    elif varfile2:
        var_arg2 = '-var-file=' + varfile2 + '.tfvars'
        subprocess.run(['terraform', 'apply', var_arg, var_arg2, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
        subprocess.run(['terraform', 'plan', var_arg, var_arg2, '-detailed-exitcode'], check=True, capture_output=True)
    else:
        raise Exception('Too many arguments: update_test()')

    subprocess.run('terraform show', shell=True, check=True, capture_output=True)


def destroy_test(varfile=None, varval=None, timeout=None):
    if (varfile == None) and (varval == None):
        subprocess.run('terraform destroy -auto-approve', shell=True, check=True, capture_output=True, timeout=timeout)
    elif (varfile) and (varval == None):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'destroy', var_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    elif (varfile == None) and (varval):
        subprocess.run(['terraform', 'destroy', '-var', varval, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    elif (varfile) and (varval):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'destroy', var_arg, '-var', varval, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    else:
        raise Exception('Too many arguments: destroy_test()')

    subprocess.run('terraform show', shell=True, check=True, capture_output=True)


def destroy_target(resource, name, varfile=None, varval=None, timeout=None):
    target_arg = '-target=aviatrix_' + resource + '.' + name
    if (varfile == None) and (varval == None):
        subprocess.run(['terraform', 'destroy', target_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    elif (varfile) and (varval == None):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'destroy', target_arg, var_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    elif (varfile == None) and (varval):
        subprocess.run(['terraform', 'destroy', '-var', varval, target_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    elif (varfile) and (varval):
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'destroy', target_arg, var_arg, '-var', varval, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    else:
        raise Exception('Too many arguments: destroy_target()')

    subprocess.run('terraform show', shell=True, check=True, capture_output=True)


def generic_destroy_target(resource, name, varfile=None, timeout=None):
    target_arg = '-target=' + resource + '.' + name
    if varfile == None:
        subprocess.run(['terraform', 'destroy', target_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    elif varfile:
        var_arg = '-var-file=' + varfile + '.tfvars'
        subprocess.run(['terraform', 'destroy', target_arg, var_arg, '-auto-approve'], check=True, capture_output=True, timeout=timeout)
    else:
        raise Exception('Too many arguments: destroy_target()')

    subprocess.run('terraform show', shell=True, check=True, capture_output=True)
