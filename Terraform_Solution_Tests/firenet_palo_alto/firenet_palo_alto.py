#! /usr/bin/python3

"""
firenet_palo_alto.py script will test following:
* SSH to private instance and try ping test for the list of targeted IP addresses
* If ping fails, retry 3 times.
* SSH to firewall management IP and verify traffic is hitting firewall.
* Write PASS/FAIL to result file.
"""
import pexpect
import sys
import time
import re
import os
import getopt
import subprocess

def main(argv):
  result = 'PASS'
  ping_list = ''
  instance = ''
  firewall_ip = ''
  if len(argv) == 0:
    print('usage: PROG [-h] --ping_list <list_of_ip_addresses> --instance <IP> --firewall_ip <IP>')
    sys.exit(2)
  try:
    opts, args = getopt.getopt(argv,'h',['ping_list=','instance=','firewall_ip='])
  except getopt.GetoptError:
    print('usage: PROG [-h] --ping_list <list_of_ip_addresses> --instance <IP> --firewall_ip <IP>')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print('usage: PROG [-h] --ping_list <list_of_ip_addresses> --instance <IP> --firewall_ip <IP>')
      sys.exit()
    elif opt in ('',"--ping_list"):
        ping_list = arg.split(",")
    elif opt in ('',"--instance"):
        instance = arg
    elif opt in ('',"--firewall_ip"):
        firewall_ip = arg

  f = open('/tmp/log.txt','w')
  f.write('Sleeping 10min for Firewall VM instance to fully come up ...\n')
  time.sleep(600)   # Wait for 10min

  # Attempting SSH to Palo Alto Firewall VM for clearing logs
  f.write('Connecting SSH to Firewall for clearing the logs ...\n')
  ssh_retry = 0
  ssh_error = -1
  while (ssh_error!=0) and (ssh_retry < 5):
    firewall_vm = pexpect.spawn('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@'+firewall_ip)
    ssh_error = firewall_vm.expect(['\> ', pexpect.TIMEOUT, 'Password: ', 'Connection refused', 'System initializing'])
    if ssh_error != 0:
        f.write('Failed SSH to Firewall. Will re-try. Sleeping 1 min ... \n')
        firewall_vm.close()
        time.sleep(60)
    ssh_retry += 1
  if ssh_error != 0:
    f.write('Failed SSH to Firewall Management IP '+firewall_ip+'\n')
    if ssh_error != 1:
      f.write(firewall_vm.before.decode("utf-8"))
      f.write(firewall_vm.after.decode("utf-8"))
    f.write('\nEnding the test .... \n')
    sys.exit(2)
  else:
    f.write('Successful SSH to Firewall Management IP '+firewall_ip+'\n')
    f.write(subprocess.getoutput('date')+'  :Clearing logs on Palo Alto Firewall VM ...\n')
    firewall_vm.sendline('clear log traffic')
    firewall_vm.expect('y or n\) ')
    firewall_vm.sendline('y')
    firewall_vm.expect('\> ')
    firewall_output = firewall_vm.before
    m = re.search('Successfully deleted traffic logs',firewall_output.decode('utf-8'))
    if m:
      f.write(firewall_output.decode("utf-8"))
      f.write('\n')
      f.write(subprocess.getoutput('date')+'  :Successful clearning logs on Palo Alto Firewall ...\n')
    else:
      f.write(subprocess.getoutput('date')+'  :Failed to clear logs on Palo Alto Firewall. Continuing test ...\n')
  firewall_vm.close()

  # Attempting SSH to private Ubuntu VM instance for testing end-to-end traffic
  f.write('Connecting SSH to '+instance+'\n')
  p = pexpect.spawn('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@'+instance)
  ssh_error = p.expect(['\$ ', pexpect.TIMEOUT, 'publickey'])
  if ssh_error != 0:
    f.write('Failed SSH to '+instance+'\n')
    if ssh_error != 1:
      f.write(p.before.decode("utf-8"))
      f.write(p.after.decode("utf-8"))
    f.write('\nEnding the test .... \n')
    sys.exit(2)
  else:
    f.write('Successful SSH to '+instance+'\n')

  f.write(subprocess.getoutput('date')+'  :Starting traffic test ...\n')
  '''
    Try ping test for each IP that is supposed to work.
    If ping fails, it will re-try up to 3 times.
  '''
  i = 0
  num_of_tries = 0
  while i < len(ping_list):
    cmd = 'ping -c 3 ' + ping_list[i]
    f.write(subprocess.getoutput('date')+'  :Trying to execute ping cmd to '+ping_list[i]+' ...\n')
    p.sendline(cmd)
    p.expect('\$ ')
    output = p.before
    f.write(subprocess.getoutput('date')+'  :Successfully executed ping cmd to '+ping_list[i]+' ...\n')
    m = re.search(rb'3 received',output)
    if m:
      f.write(subprocess.getoutput('date')+'  :Ping traffic flows to '+ping_list[i]+' ...\n')
      i += 1
      num_of_tries = 0
    elif num_of_tries < 3:
      num_of_tries += 1
      f.write('############### Traffic Failed. Will retry ... ###############\n')
      f.write('Executed cmd >>>>> '+cmd+'\n')
      f.write('Number of Tries: '+str(num_of_tries)+'\n')
      f.write(subprocess.getoutput('date')+'  :Will try again. Sleeping now ...\n')
      time.sleep(num_of_tries*10)
    else:
      result = 'FAIL'
      i += 1
      num_of_tries = 0
      f.write('################ Test Failed after 3 re-tries ################\n')
      f.write('Executed cmd >>>>> '+cmd+'\n')
      f.write('Output : \n')
      f.write(output.decode("utf-8"))
      f.write('\n')
      f.write('##############################################################\n')

  # Checking whether traffic is hitting Firewall instance
  f.write(subprocess.getoutput('date')+'  :Checking traffic on Palo Alto Firewall ...\n')
  f.write('Connecting SSH to Firewall Management IP '+firewall_ip+'\n')
  palo_alto_vm = pexpect.spawn('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null admin@'+firewall_ip)
  ssh_error = palo_alto_vm.expect(['\> ', pexpect.TIMEOUT, 'Password: '])
  if ssh_error != 0:
    f.write('Failed SSH to Firewall Management IP '+firewall_ip+'\n')
    if ssh_error != 1:
      f.write(palo_alto_vm.before.decode("utf-8"))
      f.write(palo_alto_vm.after.decode("utf-8"))
    f.write('\nEnding the test .... \n')
    sys.exit(2)
  else:
    f.write('Successful SSH to Firewall Management IP '+firewall_ip+'\n')

  f.write(subprocess.getoutput('date')+'  :Sleeping 20sec for logs collection ...\n')
  time.sleep(20)
  traffic_pass_list = []
  traffic_fail_list = []
  for i in range(len(ping_list)):
    palo_alto_cmd = 'show log traffic src in '+instance+' | match '+ping_list[i]
    f.write('Sending Palo Alto cmd >>>>> '+ palo_alto_cmd+' ...\n')
    palo_alto_vm.sendline(palo_alto_cmd)
    palo_alto_vm.readline()
    palo_alto_vm.expect('\> ')
    f.write('Checking in Palo Alto Firewall VM log for '+ ping_list[i]+' ...\n')
    palo_alto_output = palo_alto_vm.before
    m = re.search(ping_list[i],palo_alto_output.decode('utf-8'))
    if m:
      traffic_pass_list.append(ping_list[i])
    else:
      result = 'FAIL'
      traffic_fail_list.append(ping_list[i])

  if len(traffic_pass_list) != 0:
      f.write('###################### Below Test Passes #####################\n')
      f.write('Traffic is successfully routed to Firewall for following IPs:\n')
      for i in range(len(traffic_pass_list)):
        f.write(traffic_pass_list[i]+'\n')
      f.write('##############################################################\n\n')
  if len(traffic_fail_list) != 0:
      f.write('################ Test Failed (Firewall Issue) ################\n')
      f.write('Palo Alto Firewall did not see the following traffic flow(s)\n')
      for i in range(len(traffic_fail_list)):
        f.write(traffic_fail_list[i]+'\n')
      f.write('##############################################################\n\n')

  p.close()
  palo_alto_vm.close()
  f.close()

  with open('/tmp/result.txt','w') as result_file:
    result_file.write(result+'\n')

if __name__ == "__main__":
  main(sys.argv[1:])
