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
    parameters: dict

@dataclass
class Actions:
    name: str
    parameters: list
    preconditions: list
    effects: list

class DomainCreator:
    def __init__(self, environment_path, domain_path, new_domain_name="test"):
        self.domain_name = new_domain_name
        self.environment_path = environment_path
        self.domain_path = domain_path
        self.domain_components = {}

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
        
    def breakdown_domain(self):
        components = self.split_components()
        for idx, component in enumerate(components):
            if component.startswith("(define"):
                self.domain_components["domain"] = DomainName(self.domain_name)
            elif component.startswith("requirements"):
                self.domain_components["requirements"] = self.requirement_breakdown(component)
            elif component.startswith("types"):
                self.domain_components["types"] = self.type_breakdown(" ".join(component.split(" ")[1:]))
            elif component.startswith("constants"):
                self.domain_components["constants"] = self.constant_breakdown(" ".join( component.split(" ")[1:]))
            elif component.startswith("predicates"):
                self.domain_components["predicates"] = self.predicate_breakdown(" ".join(component.split(" ")[1:]))
            elif component.startswith("functions"):
                self.domain_components["functions"] = self.function_breakdown(" ".join(component.split(" ")[1:]))
            elif component.startswith("action"):
                self.domain_components["actions"] = self.action_breakdown(" ".join(component.split(" ")[1:]))

    def split_components(self):
        return self.domain.split("(:")
    
    def requirement_breakdown(self, requirements):
        requirements = requirements.replace(")", "")
        requirements = requirements.split(":")[1:]
        return requirements
    
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
    
    def constant_breakdown(self, constants):
        constants = constants.replace(")", "")
        constants = constants.split("\n")
        temp_list = []
        for c in constants:
            const = c.split(" ")
            const = list(filter(None, const))
            if "-" in const:
                temp_list.append(Constants(const[0], const[-1]))
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
        preconditions = preconditions.replace(")", "").replace("(and ", "").replace("\n", " ")
        conditions = preconditions.split("(")
        conditions = list(filter(None, conditions))
        conditions_list = []
        variables = []
        for co in conditions:
            temp = co.split(" ")
            temp = list(filter(None, temp))
            if temp:
                conditions_list.append(temp[0])
                variables.append(" ".join(temp[1:]))
        conditions = []
        for idx, var in enumerate(variables):
            conditions.append(Predicates(conditions_list[idx], self.parameter_breakdown(var)))
        return conditions
    
    def effect_breakdown(self, effects):
        effects = effects.replace(")", "").replace("(and ", "").replace("\n", " ")
        effects = effects.split("(")
        effects = list(filter(None, effects))
        effect_list = []
        variables = []
        not_list = [False for _ in range(len(effects))]
        for idx, eff in enumerate(effects):
            temp = eff.split(" ")
            temp = list(filter(None, temp))
            if temp:
                if temp[0] == "not":
                    not_list[idx] = True
                else:
                    effect_list.append(temp[0])
                    variables.append(" ".join(temp[1:]))
        effects = []
        for idx, var in enumerate(variables):
            if not_list[idx]:
                effects.append(Predicates(f"not ({effect_list[idx]}", self.parameter_breakdown(var)))
            else:
                effects.append(Predicates(effect_list[idx], self.parameter_breakdown(var)))
        return effects
        
    def create_requirements(self, requirements):
        format = "(:requirements "
        for req in requirements:
            format += req + " "
        format += ")\n\n"
        return format
    
    def create_types(self, types):
        format = "(:types\n"
        for ty in types:
            if ty.subtype:
                format += f"    {ty.name} - {ty.subtype}\n"
            else:
                format += f"    {ty.name}\n"
        format += ")\n\n"
        return format
    
    def create_constants(self, constants):
        if not constants:
            return ""
        format = "(:constants\n"
        for const in constants:
            format += f"    {const.name} - {const.type}\n"
        format += ")\n\n"
        return format
    
    def create_parameters(self, parameters, for_action=False, for_conditions=False):
        if for_action:
            if for_conditions:
                format = ""
            else:
                format = ":parameters ("
            for key, value in parameters.items():
                if for_action and not for_conditions:
                    format += f"?{key} - {value} "
                elif for_conditions:
                    format += f"?{key} "
            if for_conditions:
                return format
            format += ")\n"
            return format
        format = ""
        for key, value in parameters.items():
            format += f"?{key} - {value} "
        return format
    
    def create_predicates(self, predicates, for_action = False, for_conditions = False):
        if not for_action:
            format = "(:predicates\n"
        else:
            format = ""
        for pred in predicates:
            if pred.name.startswith("not"):
                format += f"    ({pred.name} {self.create_parameters(pred.parameters, for_action, for_conditions)})) "
            format += f"    ({pred.name} {self.create_parameters(pred.parameters, for_action, for_conditions)})\n"
        if for_action:
            format += ")\n"
            return format
        format += ")\n\n"
        return format
    
    def create_functions(self, functions):
        if not functions:
            return ""
        format = "(:functions\n"
        for func in functions:
            if func.parameters:
                format += f"    ({func.name} {self.create_parameters(func.parameters)})\n"
            else:
                format += f"    {func.name}\n"
        format += ")\n\n"
        return format
    
    def create_preconditions(self, preconditions):
        format = ":precondition (and "
        for precond in preconditions:
            format += f"{precond}"
        format += ")"
        return format
    
    def create_effects(self, effects):
        format = ":effect (and "
        for effect in effects:
            format += f"    {effect}"
        format += ")"
        return format
    
    def create_actions(self, actions):
        format = ""
        for action in actions:
            format += f"(:action {action.name}\n"
            format += f"    {self.create_parameters(action.parameters, True)}\n"
            format += f"    {self.create_preconditions(action.preconditions)}\n"
            format += f"    {self.create_effects(action.effects)}\n)\n"
        return format
        
    def create_domain(self):
        domain = "( define (domain " + self.domain_name + ")\n"
        domain += self.create_requirements(self.domain_components["requirements"])
        domain += self.create_types(self.domain_components["types"])
        domain += self.create_constants(self.domain_components["constants"])
        domain += self.create_predicates(self.domain_components["predicates"])
        domain += self.create_functions(self.domain_components["functions"])
        domain += self.create_actions(self.domain_components["actions"])
        domain += ")"
        return domain

            
        
creator = DomainCreator("open_world.json", "initial.pddl")
loaded = creator.load_domain()
if loaded:
    creator.breakdown_domain()
    print(creator.create_domain())