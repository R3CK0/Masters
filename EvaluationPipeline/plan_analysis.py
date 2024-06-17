import subprocess

subprocess.os.chdir("/home/god/Documents/Masters")
popf_path = "/home/god/.planutils/packages/popf"

plan_command = f"./run /home/god/Documents/Masters/data/IPC3/Tests1/Depots/Numeric/AI_gen/Depots_Nu_0.pddl /home/god/Documents/Masters/data/IPC3/Tests1/Depots/Numeric/problems/pfile1"

plan = subprocess.Popen(plan_command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = plan.communicate()
print(out.decode("utf-8"))