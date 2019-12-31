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

  p = pexpect.spawn('ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@'+instance)
  f = open('/tmp/log.txt','w')
  f.write('Connecting SSH to '+instance+'\n')
  p.expect('\$ ')
  f.write('Successful SSH to '+instance+'\n')
  for i in range(len(domain)):
    if port[i] in ['443','80','ping','all']:
      if domain[i].startswith('*'):
          url = 'https://www.' + domain[i].lstrip('*.')
      else:
          url = 'https://' + domain[i]
      if port[i] in ['443','80'] and proto[i] in ['tcp','https']:
          cmd = 'wget -t 1 -T 3 ' + url
      elif proto[i] in ['icmp','all']:
          cmd = 'ping -c 3 ' + domain[i]
      f.write('Executing command: '+cmd+'\n')
      p.sendline(cmd)
      time.sleep(3)
      p.expect('\$ ')
      f.write('Successfully executed command: '+cmd+'\n')
      output = p.before
      if port[i] in ['443','80'] and proto[i] in ['tcp','https']:
          m = re.search(rb'200 OK', output)
      elif proto[i] in ['icmp','all']:
          m = re.search(rb'3 received', output)
      if (m and mode=='white') or (not m and mode=='black'):
        f.write('Test Pass for FQDN '+domain[i]+' filter'+'\n')
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
    result_file.write(result)

if __name__ == "__main__":
  main(sys.argv[1:])
