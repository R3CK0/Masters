import json
from openai import OpenAI
import os
import re


def natural_keys(text):
    return [int(c) if c.isdigit() else c.lower() for c in re.split('([0-9]+)', text)]


def create_jsonl_format(subdomain, prompt, id, nl=False):
    jsonl = []
    for idx, (domain, prompt) in enumerate(zip(subdomain, prompt)):
        start_index = domain.find("(define")
        dom = domain[start_index:]
        if nl:
            ids = id+str(idx)+"_nl"
        else:
            ids = id+str(idx)
        jsonl.append({"custom_id": ids, "method":"POST", "url":"/v1/chat/completions", "body":{"model": "gpt-4o", "messages": [{"role": "system", "content": "You are a PDDL domain creation expert, you modify domains based on requested changes."},{"role": "user", "content": f"{prompt}\n\n{dom}"}],"max_tokens": 3000}})
    return jsonl

def create_jsonl_batch(root):
    path = os.path.abspath(root)
    batch_json = []
    for domain in ["Depots", "DriverLog", "Rovers"]:
        for req in ["Numeric", "SimpleTime", "Strips", "Time"]:
            prompt_files = os.listdir(os.path.join(path,domain,req, "labels"))
            nl_prompts = sorted([prompts for prompts in prompt_files if prompts.endswith("nl.txt")], key=natural_keys)
            reg_prompts = sorted([prompts for prompts in prompt_files if not prompts.endswith("nl.txt")], key=natural_keys)
            
            subdomain_files = os.listdir(os.path.join(path,domain,req, "subdomains"))
            subdomains = [subdomain for subdomain in subdomain_files if subdomain.__contains__("_sub")]
            
            sub_prompt = []
            for subdomain in subdomains:
                with open(os.path.join(path,domain,req, "subdomains", subdomain), "r") as f:
                    sub_prompt.append(f.read())
            
            nl_pr = []
            for prompt in nl_prompts:
                with open(os.path.join(path,domain,req, "labels", prompt), "r") as f:
                    nl_pr.append(f.read())
                    
            reg_pr = []
            for prompt in reg_prompts:
                with open(os.path.join(path,domain,req, "labels", prompt), "r") as f:
                    reg_pr.append(f.read())
            
            print("creating jsonl file for ", domain, req)
            nl_jsonl = create_jsonl_format(sub_prompt, nl_pr, f"{domain}_{req[:2]}", True)
            reg_jsonl = create_jsonl_format(sub_prompt, reg_pr, f"{domain}_{req[:2]}")
            batch_json.extend(nl_jsonl)
            batch_json.extend(reg_jsonl)
    with open("batch.jsonl", "w") as file:
        for line in batch_json:
            file.write(json.dumps(line))
            file.write("\n")

def upload_batch(client, jsonl_file):
    batch_file_input = client.files.create(
        file=open(jsonl_file, "rb"),
        purpose="batch"
    )
    save_batch_info("openai_batch_info", batch_file_input)
    print("Batch file uploaded successfully")
    return batch_file_input

def save_batch_info(name, data):
    with open("batch_info.json", "w") as file:
        json.dump({name: data}, file)

def start_run(client):
    with open("batch_info.json", "r") as file:
        batch_info = json.load(file)["openai_batch_info"]
    input_file_id = batch_info["id"]
    run = client.batches.create(
        input_file_id=input_file_id,
        endpoint="v1/chat/completions",
        completion_window="24h",
        metadata={"description": "Evaluation run with no code"}    
    )
    save_batch_info("openai_run_info", run)
    print("Run started successfully")



#create_jsonl_batch("data/IPC3/Tests1/")
with open("OPENAI_KEY.json", 'r') as json_file:
        data = json.load(json_file)
        client = OpenAI(api_key=data['openai_key'])

upload_batch(client, "batch.jsonl")