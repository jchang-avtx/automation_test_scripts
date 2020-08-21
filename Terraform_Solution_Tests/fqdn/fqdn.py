#! /usr/bin/python3

import pexpect
import sys
import time
import re
import os
import getopt

def main(argv):
  result = 'PASS'
  enabled = 'true'
  mode = 'white'
  domain = ''
  proto = ''
  port = ''
  instance = ''
  if len(argv) == 0:
    print('usage: PROG [-h] --enabled <true/false> --mode <white/black> --domain <domain> --proto <protocol> --port <port> --instance <IP>')
    sys.exit(2)
  try:
    opts, args = getopt.getopt(argv,'h',['enabled=','mode=','domain=','proto=','port=','instance='])
  except getopt.GetoptError:
    print('usage: PROG [-h] --enabled <true/false> --mode <white/black> --domain <domain> --proto <protocol> --port <port> --instance <IP>')
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print('usage: PROG [-h] --enabled <true/false> --mode <white/black> --domain <domain> --proto <protocol> --port <port> --instance <IP>')
      sys.exit()
    elif opt in ('',"--enabled"):
        enabled = arg
    elif opt in ('',"--mode"):
        mode = arg
    elif opt in ('',"--domain"):
        domain = arg.split(",")
    elif opt in ('',"--proto"):
        proto = arg.split(",")
    elif opt in ('',"--port"):
        port = arg.split(",")
    elif opt in ('',"--instance"):
        instance = arg
  if (len(domain) != len(proto)) or (len(domain) != len(port)):
    print('Number of FQDN filter arguments not the same!!!')
    print('Total domain = ',len(domain),'(',domain,')')
    print('Total proto = ',len(proto),'(',proto,')')
    print('Total port = ',len(port),'(',port,')')
    sys.exit(2)
  p = pexpect.spawn('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@'+instance)
  f = open('/tmp/log.txt','w')
  f.write('Connecting SSH to '+instance+'\n')
  p.expect('\$ ')
  f.write('Successful SSH to '+instance+'\n')
  for i in range(len(domain)):
    num_of_tries = 0
    if port[i] in ['443','80','ping','all']:
      if port[i] in ['443']:
          url = 'https://'
      elif port[i] in ['80']:
          url = 'http://' 
      if domain[i].startswith('*'):
          url = url + 'www.' + domain[i].lstrip('*.')
      else:
          url = url + domain[i]
      if port[i] in ['443','80'] and proto[i] in ['tcp','https']:
          cmd = 'wget -t 1 -T 3 ' + url
      elif proto[i] in ['icmp','all']:
          cmd = 'ping -c 3 ' + domain[i]
      # Traffic test will be done by running corresponding command.
      # If traffric fails, it will re-try up to 3 times.
      while num_of_tries <= 3:
        f.write('Executing command: '+cmd+'\n')
        p.sendline(cmd)
        p.expect('\$ ')
        f.write('Successfully executed command: '+cmd+'\n')
        output = p.before
        if port[i] in ['443','80'] and proto[i] in ['tcp','https']:
            m = re.search(rb'200 OK', output)
        elif proto[i] in ['icmp','all']:
            m = re.search(rb'3 received', output)
        if (m and mode=='white') or (not m and mode=='black'):
          f.write('#################### Below Test Passes ####################\n')
          f.write('Test Pass for FQDN '+domain[i]+' filter'+'\n')
          f.write('###########################################################\n')
          break
        num_of_tries += 1
        if num_of_tries <= 3:
          f.write('###################### Traffic Failed ######################\n')
          f.write('Executed cmd >>>>> '+cmd+'\n')
          f.write('Number of Tries: '+str(num_of_tries)+'\n')
          f.write('Will try again. Sleeping for sometime....\n')
          time.sleep(num_of_tries*60)
        else:
          result = 'FAIL'
          f.write('***************** Following test failed *****************\n')
          f.write('FQDN Domain Name = '+domain[i]+'\n')
          f.write('FQDN Protocol = '+ proto[i]+'\n')
          f.write('FQDN Port = '+ port[i]+'\n')
          f.write('Test Output: \n')
          f.write(output.decode("utf-8"))
          f.write('\n')
          f.write('*********************************************************\n')
  f.close()
  with open('/tmp/result.txt','w') as result_file:
   result_file.write(result+'\n')
  sys.exit(0)

if __name__ == "__main__":
  main(sys.argv[1:])
