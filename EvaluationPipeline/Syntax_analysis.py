import subprocess
import os
import json


subprocess.os.chdir("/home/god/Documents/Masters")

syntax = []

path = "data/IPC3/Tests1"
path = os.path.abspath(path)

domains_path = "AI_gen"

val_path = '~/.config/Code/User/globalStorage/jan-dolejsi.pddl/val/Val-20210401.1-Linux/bin'
full_val_path = subprocess.os.path.expanduser(val_path)
#syntax = {"Depots": {"Numeric": {}, "SimpleTime": {}, "Strips": {}, "Time": {}}, "DriverLog": {"Numeric": {}, "SimpleTime": {}, "Strips": {}, "Time": {}}, "Rovers": {"Numeric": {}, "SimpleTime": {}, "Strips": {}, "Time": {}}}

subprocess.os.chdir(full_val_path)

for domain in ["Depots", "DriverLog", "Rovers"]:
    for req in ["Numeric", "SimpleTime", "Strips", "Time"]:
        for file in os.listdir(os.path.join(path, domain, req, domains_path)):
            pddl_path = os.path.join(path, domain, req, domains_path, file)

            # Expand the user tilde to the user's home directory path
            full_pddl_path = os.path.expanduser(pddl_path)
            val_command = f'./Parser {full_pddl_path}'            
            
            val_process = subprocess.Popen(val_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            stdout, stderr = val_process.communicate()

            output = stdout.decode('utf-8')
            error = stderr.decode('utf-8')
            
            try:
                out = output.split("(derivations_list)")[1]
            except:
                print(f"{domain} {req} {file}")
                syntax.append({"domain": domain, "requirement": req, "file": file, "errors": -1, "warnings": -1, "error_list": ["Unknown error"]})
                continue
            
            errors = int(out[out.index("Errors:")+8:out.index("warnings:")-2])
            warnings = int(out[out.index("warnings:")+9:out.index("warnings:")+11])
            list_errors = []
            list_warnings = []
            if errors > 0 or warnings > 0:
                out = out.split("\n")[1:]
                for line in out:
                    if "Error:" in line:
                        error = line[line.index("Error: ")+7:]
                        list_errors.append(error)
                    elif "Warning:" in line:
                        warning = line[line.index("Warning: ")+9:]
                        list_warnings.append(warning)

            syntax.append({"domain": domain, "requirement": req, "file": file, "errors": errors, "warnings": warnings, "error_list": list_errors, "warning_list": list_warnings})

subprocess.os.chdir("/home/god/Documents/Masters")
with open(f"syntax-{domains_path}.jsonl", "w") as f:
    for syn in syntax:
        json.dump(syn, f)
        f.write("\n")