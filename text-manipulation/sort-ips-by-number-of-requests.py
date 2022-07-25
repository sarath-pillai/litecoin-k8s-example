import collections
import sys

ips = []
ips_sorted = {}

try:
    with open(sys.argv[1], 'r') as access_log:
        for line in access_log:
            ip = line.split(' ')[0]
            ips.append(ip)

    out = collections.Counter(ips)
    final = sorted(out.items(), key=lambda item: (-item[1], item[0]))

    for key, value in final:
         print(value, key)
except Exception as e:
    print("Unexpected Error occured: ", e)
