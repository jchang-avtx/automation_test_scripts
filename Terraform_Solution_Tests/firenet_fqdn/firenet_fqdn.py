#! /usr/bin/python3

"""
firenet_fqdn.py script will test following:
* Try ping test for all IP addresses in both ping_allow_list and ping_deny_list
* If ping fails, retry 3 times.
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
  ping_allow_list = ''
  ping_deny_list = ''
  instance = ''
  if len(argv) == 0:
    print('usage: PROG [-h] --ping_allow_list <list_of_ip_addresses> --ping_deny_list <list_of_ip_addresses> --instance <IP>')
    sys.exit(2)
  try:
    opts, args = getopt.getopt(argv,'h',['ping_allow_list=','ping_deny_list=','instance='])
  except getopt.GetoptError:
    print('usage: PROG [-h] --ping_allow_list <list_of_ip_addresses> --ping_deny_list <list_of_ip_addresses> --instance <IP>')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print('usage: PROG [-h] --ping_allow_list <list_of_ip_addresses> --ping_deny_list <list_of_ip_addresses> --instance <IP>')
      sys.exit()
    elif opt in ('',"--ping_allow_list"):
        ping_allow_list = arg.split(",")
    elif opt in ('',"--ping_deny_list"):
        ping_deny_list = arg.split(",")
    elif opt in ('',"--instance"):
        instance = arg

  f = open('/tmp/log.txt','w')

  # Attempting SSH to private Ubuntu instance for testing end-to-end traffic
  f.write('Connecting SSH to '+instance+'\n')
  p = pexpect.spawn('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@'+instance)
  ssh_error = p.expect(['\$ ', pexpect.TIMEOUT, 'publickey'])
  if ssh_error != 0:
    f.write('Failed SSH to '+instance+'\n')
    if ssh_error != 1:
      f.write(p.before.decode("utf-8"))
      f.write(p.after.decode("utf-8"))
    f.write('\nEnding the test .... \n')
  else:
    f.write('Successful SSH to '+instance+'\n')
    f.write(subprocess.getoutput('date')+'  :Starting traffic test ...\n')
    '''
      Try ping test for each IP that is supposed to work.
    '''
    i = 0
    num_of_tries = 0
    while i < len(ping_allow_list):
      cmd = 'ping -c 3 ' + ping_allow_list[i]
      f.write(subprocess.getoutput('date')+'  :Trying to execute ping cmd to '+ping_allow_list[i]+' ...\n')
      p.sendline(cmd)
      p.expect('\$ ')
      output = p.before
      f.write(subprocess.getoutput('date')+'  :Successfully executed ping cmd to '+ping_allow_list[i]+' ...\n')
      m = re.search(rb'3 received',output)
      if m:
        f.write('###################### Below Test Passes #####################\n')
        f.write('Test Passes for cmd >>>>> '+cmd+'\n')
        f.write('##############################################################\n')
        i += 1
        num_of_tries = 0
      elif num_of_tries < 3:
        num_of_tries += 1
        f.write('############### Traffic Failed. Will retry ... ###############\n')
        f.write('Executed cmd >>>>> '+cmd+'\n')
        f.write('Number of Tries: '+str(num_of_tries)+'\n')
        f.write(subprocess.getoutput('date')+'  :Will try again. Sleeping now ...\n')
        time.sleep(num_of_tries*20)
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
    '''
      Try ping test for each IP that is supposed to be blocked.
    '''
    i = 0
    while i < len(ping_deny_list):
      cmd = 'ping -c 3 ' + ping_deny_list[i]
      f.write(subprocess.getoutput('date')+'  :Trying to execute ping cmd to '+ping_deny_list[i]+' ...\n')
      p.sendline(cmd)
      p.expect('\$ ')
      output = p.before
      f.write(subprocess.getoutput('date')+'  :Successfully executed ping cmd to '+ping_deny_list[i]+' ...\n')
      m = re.search(rb'0 received',output)
      if m:
        f.write('###################### Below Test Passes #####################\n')
        f.write('Test Passes for cmd >>>>> '+cmd+'\n')
        f.write('##############################################################\n')
      else:
        result = 'FAIL'
        f.write('########## Below Test Failed (Ping should NOT work) ##########\n')
        f.write('Executed cmd >>>>> '+cmd+'\n')
        f.write('Output : \n')
        f.write(output.decode("utf-8"))
        f.write('\n')
        f.write('##############################################################\n')
      i += 1

  p.close()
  f.close()

  with open('/tmp/result.txt','w') as result_file:
    result_file.write(result+'\n')

if __name__ == "__main__":
  main(sys.argv[1:])
