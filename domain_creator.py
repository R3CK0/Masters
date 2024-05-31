import json
from dataclasses import dataclass

@dataclass
class DomainName:
    name: str
    
@dataclass
class Requirements:
    requirements: list

@dataclass
class Types:
    name: str
    subtype: str

@dataclass
class Constants:
    name: str
    type: str

@dataclass
class Predicates:
    name: str
    parameters: dict
    
@dataclass
class Functions:
    name: str
    parameters: list

@dataclass
class Actions:
    name: str
    parameters: list
    preconditions: list
    effects: list

class DomainCreator:
    def __init__(self, environment_path, domain_path):
        self.domain_name = None
        self.environment_path = environment_path
        self.domain_path = domain_path
        self.domain_components = []

    def load_environment(self):
        try:
            with open(self.environment_path, 'r') as file:
                self.environment = json.load(file)
        except FileNotFoundError:
            print("Environment file not found.")
            return False
    
    def load_domain(self):
        try:
            with open(self.domain_path, 'r') as file:
                self.domain = file.read()
        except FileNotFoundError:
            print("Domain file not found.")
            return False

    def split_components(self):
        return self.domain.split("(:")
    
    def type_breakdown(self, types):
        types = types.replace(")", "")
        types = types.split("\n")
        temp_list = []
        for t in types:
            ty = t.split(" ")
            ty = list(filter(None, ty))
            if "-" in ty:
                variables = ty[:-2]
                subtype = ty[-1]
                for var in variables:
                    temp_list.append(Types(var, subtype))
            else:
                if ty:
                    temp_list.append(Types(ty[0], None))
        return temp_list
    
    def predicate_breakdown(self, predicate):
        predicates = predicate.split("\n")
        predicates = list(filter(None, predicates))
        predicates = [pred.replace(")", "").replace("(", "") for pred in predicates]
        predicate_list = []
        variables = []
        for pred in predicates:
            temp = pred.split(" ")
            temp = list(filter(None, temp))
            if temp:
                predicate_list.append(temp[0])
                variables.append(" ".join(temp[1:]))
        predicates = []
        for idx, var in enumerate(variables):
            predicates.append(Predicates(predicate_list[idx], self.parameter_breakdown(var)))
        return predicates
    
    def function_breakdown(self, function):
        functions = function.split("(")
        function_list = []
        for function in functions:
            function = function.replace(")", "").replace("\n", "")
            function = function.split(" ")
            function = list(filter(None, function))
            if function:
                if len(function) > 1:
                    function_list.append(Functions(function[0], self.parameter_breakdown(" ".join(function[1:]))))
                else:
                    function_list.append(Functions(function[0], None))
        return function_list
    
    def action_breakdown(self, action):
        action = action.split(":")
        
        name = action[0].strip()
        parameters = action[1].replace("(", "").replace(")", "").replace("\n", "").replace("parameters ", "")
        preconditions = action[2].replace("\n", "").replace("precondition ", "")
        effects = action[3].replace("\n", "").replace("effect ", "")
        print(f"Name : {name}, \nparameters: {parameters}, \npreconditions: {preconditions}, \nEffects: {effects}\n")
        return [name, parameters, preconditions, effects]
    
    def parameter_breakdown(self, parameters):
        variables = parameters.split("?")
        for idx, var in enumerate(variables):
            variables[idx] = var.split(" ")[0]
        parameters = parameters.split("-")
        temps_list = []
        for param in parameters:
            param = param.replace("?", "")
            param = param.split(" ")
            temps_list.extend(param)
        variables = list(filter(None, variables))
        temps_list = list(filter(None, temps_list))
        parameters = {}
        param_list = []
        for param in temps_list:
            if param in variables:
                param_list.append(param)
            else:
                for var in param_list:
                    parameters[var] = param
                param_list = []
            
        return parameters
    
    def precondition_breakdown(self, preconditions):
        pass
    
    def effect_breakdown(self, effects):
        pass
        
        
        
creator = DomainCreator("open_world.json", "initial.pddl")
creator.load_domain()
for idx, component in enumerate(creator.split_components()):
    if component.startswith("functions"):
        action = " ".join(component.split(" ")[1:])
        print(f"functions")
        print(creator.function_breakdown(action))
        #[_, params, _, _] = creator.action_breakdown(action)
        #creator.parameter_breakdown(params)
    else:
        print(f"component {idx} : {component}")