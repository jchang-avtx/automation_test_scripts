import requests

url="https://s3-us-west-2.amazonaws.com/aviatrix-download/IAM_access_policy_for_CloudN.txt"
r = requests.get(url,verify=False)
with open('aviatrix_iam_role/aviatrix-app-policy.json','w') as fout:
  fout.write(r.text)
