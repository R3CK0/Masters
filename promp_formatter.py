import json

# This class loads the json file containing the modification for the domain as well 
# as the domain and any usefull pddl examples. The returns a prompt ready to be used 
# to get the new modified domain

class PromptFormatter:
    
    def __init__(self, environement_path: str, pddl_examples_path: str, domain_path: str) -> None:
        self.environement_path = environement_path
        self.pddl_examples_path = pddl_examples_path
        self.domain_path = domain_path
        self.environement = None
        self.pddl_examples = None
        self.domain = None
        self.load_files()
        
    def load_files(self):
        with open(self.environement_path) as f:
            self.environement = json.load(f)
        with open(self.pddl_examples_path) as f:
            self.pddl_examples = json.load(f)
        with open(self.domain_path) as f:
            self.domain = json.load(f)
    
    def get_prompt(self):
        pass
        