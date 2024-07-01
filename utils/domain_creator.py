import json
from dataclasses import dataclass
import os

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
    duration: None

@dataclass
class Fluent:
    operation: str # increase, decrease, set, *, /, >, <, >=, <=, =
    arg1: str
    arg2: list

@dataclass
class Duration:
    value: None

class DomainParser:
    def __init__(self, domain_path, new_domain_name="test"):
        self.domain_name = new_domain_name
        #self.environment_path = environment_path
        self.domain_path = domain_path
        self.domain_components = {}

    # def load_environment(self):
    #     try:
    #         with open(self.environment_path, 'r') as file:
    #             self.environment = json.load(file)
    #     except FileNotFoundError:
    #         print("Environment file not found.")
    #         return False
    
    def load_domain(self):
        try:
            with open(self.domain_path, 'r') as file:
                self.domain = file.read()
                return True
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
                if "actions" not in list(self.domain_components.keys()):
                    self.domain_components["actions"] = []
                self.domain_components["actions"].append(self.action_breakdown(" ".join(component.split(" ")[1:])))
            elif component.startswith("durative-action"):
                if "durative_actions" not in list(self.domain_components.keys()):
                    self.domain_components["durative_actions"] = []
                self.domain_components["durative_actions"].append(self.action_breakdown(" ".join(component.split(" ")[1:]), durative=True))

    def split_components(self):
        self.domain = self.domain.replace("\t", "")
        return self.domain.split("(:")
    
    def requirement_breakdown(self, requirements):
        requirements = requirements.replace(")", "").replace("\n", "")
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
    
    def action_breakdown(self, action, durative=False):
        action = action.split(":")
        dur = 0
        name = action[0].strip()
        parameters = action[1].replace("(", "").replace(")", "").replace("\n", "").replace("parameters ", "")
        if durative:
            duration = action[2].replace("\n", "").replace("= ?duration ", "").replace("duration ", "")
            preconditions = action[3].replace("\n", "").replace("condition ", "")
            dur = 1
        else:
            preconditions = action[2].replace("\n", "").replace("precondition ", "")
        effects = action[3+dur].replace("\n", "").replace("effect ", "")
        #print(f"Name : {name}, \nparameters: {parameters}, \npreconditions: {preconditions}, \nEffects: {effects}\n")
        
        parameters = self.parameter_breakdown(parameters)
        preconditions = self.action_change_breakdown(preconditions)
        effects = self.action_change_breakdown(effects)
        if durative:
            duration = self.duration_breakdown(duration)
            return Actions(name, parameters, preconditions, effects, duration)

        return Actions(name, parameters, preconditions, effects)
    
    def parameter_breakdown(self, parameters, precondition=False):
        parameters = parameters.replace(")", "")
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
        if precondition:
            return variables
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
    

    def duration_breakdown(self, duration):
        fluent_keywords = ["increase ", "decrease ", "set ", "> ", "< ", ">= ", "<= ", "= ", "* ", "/ ", "+ ", "- "]
        duration = duration.split("(")
        duration = list(filter(None, duration))

        if len(duration) == 1:
            return Duration(duration[0].replace(")", ""))
        else:
            fluent_depth = 0
            durative_fluent = None
            argument_path = []
            for element in duration:
                fluent = self.check_substring(element, fluent_keywords)
                temp = element.split(" ")
                temp = list(filter(None, temp))

                if temp:
                    if fluent and fluent_depth == 0:
                            durative_fluent = Fluent(temp[0], None, None)
                            fluent_depth = 1
                            argument_path = [1]
                            continue
      
                    if fluent_depth >= 0:
                            if fluent:
                                self.set_fluent_argument(durative_fluent, fluent_depth, argument_path, Fluent(temp[0], None, None))
                                argument_path.append(1)
                                fluent_depth += 1   
                            else:
                                name, params, value = self.fluent_breakdown(element, argument_path[-1])
                                if params != "":
                                    params = self.parameter_breakdown(params, True)
                                first_argument = Predicates(name, params)
                                if value != None:
                                    self.set_fluent_argument(durative_fluent, fluent_depth, argument_path, first_argument)
                                    argument_path[-1] = 2
                                    self.set_fluent_argument(durative_fluent, fluent_depth, argument_path, value)
                                    fluent_depth -= 1
                                    argument_path.pop()
                                else:
                                    self.set_fluent_argument(durative_fluent, fluent_depth, argument_path, first_argument)
                                    if argument_path[-1] == 1:
                                        argument_path[-1] = 2
                                    else:
                                        argument_path.pop()
                                        fluent_depth -= 1
                                        if fluent_depth > 0:
                                            argument_path[-1] = 2
            return Duration(durative_fluent)


    #TODO: Change naming from conditioning to changes since combined effects and preconditions
    def action_change_breakdown(self, preconditions):
        strips_keywords = ["not "]
        fluent_keywords = ["increase ", "decrease ", "set ", "> ", "< ", ">= ", "<= ", "= ", "* ", "/ ", "+ ", "- "]
        durative_keywords = ["at start ", "at end ", "over all "]

        preconditions = preconditions.replace("(and ", "").replace("\n", " ")
        conditions = preconditions.split("(")
        conditions = list(filter(None, conditions))

        name_list = []
        variables = []
        fluent_list = []

        preterm = None

        fluent_depth = 0
        ongoing_fluent = None
        argument_path = []
        for idx, co in enumerate(conditions):
            durative = self.check_substring(co, durative_keywords)
            fluent = self.check_substring(co, fluent_keywords)
            strips = self.check_substring(co, strips_keywords)

            temp = co.split(" ")
            temp = list(filter(None, temp))
            if temp:
                if durative:
                    preterm = temp[0]+" "+temp[1]
                elif fluent and fluent_depth == 0:
                    ongoing_fluent = Fluent(temp[0], None, None)
                    fluent_depth = 1
                    argument_path = [1]
                elif strips:
                    preterm = "not"
                else:
                    if fluent_depth == 0:
                        if preterm is not None:
                            name_list.append(f"{preterm} ({temp[0]}")
                            preterm = None
                        else:
                            name_list.append(temp[0])
                        variables.append(" ".join(temp[1:]))
                    elif fluent_depth >= 0:
                        if fluent:
                            self.set_fluent_argument(ongoing_fluent, fluent_depth, argument_path, Fluent(temp[0], None, None))
                            argument_path.append(1)
                            fluent_depth += 1   
                        else:
                            name, params, value = self.fluent_breakdown(co, argument_path[-1])
                            if params != "":
                                params = self.parameter_breakdown(params, True)
                            first_argument = Predicates(name, params)
                            if value != None:
                                self.set_fluent_argument(ongoing_fluent, fluent_depth, argument_path, first_argument)
                                argument_path[-1] = 2
                                self.set_fluent_argument(ongoing_fluent, fluent_depth, argument_path, value)
                                fluent_depth -= 1
                                argument_path.pop()
                            else:
                                self.set_fluent_argument(ongoing_fluent, fluent_depth, argument_path, first_argument)
                                if argument_path[-1] == 1:
                                    argument_path[-1] = 2
                                else:
                                    argument_path.pop()
                                    fluent_depth -= 1
                                    if fluent_depth > 0:
                                        argument_path[-1] = 2
                            if fluent_depth == 0:
                                fluent_list.append(ongoing_fluent)
                                ongoing_fluent = None
                                argument_path = []
                                                         
        conditions = []
        for i, var in enumerate(variables):
            conditions.append(Predicates(name_list[i], self.parameter_breakdown(var, True)))
        for fluent in fluent_list:
            conditions.append(fluent)
        return conditions
    
    #weight ?x ?y) 10) :: weight ?x ?y) ?z) :: weight) 10) :: weight) ?y) :: weight ?x)...
    def fluent_breakdown(self, fluent_string, argument):
        done = True if fluent_string.count(")") >= 2 else False # Means that the value to be affected to the function is also given by a function
        if argument == 2:
            done = False
        parts = fluent_string.split(")") # weight ?x ?y, 10, ""
        parts = list(filter(None, parts)) # weight ?x ?y, 10
        function_part = parts[0].split(" ") # weight, ?x, ?y
        function_part = list(filter(None, function_part))
        function_name = function_part[0]
        function_params = " ".join(function_part[1:])
        if not done:
            return function_name, function_params, None
        else:
            if parts[1].isdigit():
                return function_name, function_params, parts[1]
            else:
                return function_name, function_params, parts[1].replace(" ", "").replace("?", "")
    
    def set_fluent_argument(self, ongoing_fluent, depth, argument_path, value, current_depth=0):
        if current_depth == depth-1:
            if argument_path[current_depth] == 1:
                ongoing_fluent.arg1 = value
                return
            else:
                ongoing_fluent.arg2 = value
                return
        if argument_path[current_depth] == 1:
            self.set_fluent_argument(ongoing_fluent.arg1, depth, argument_path, value, current_depth+1)
        else:
            self.set_fluent_argument(ongoing_fluent.arg2, depth, argument_path, value, current_depth+1)


    # def effect_breakdown(self, effects):
    #     strips_keywords = ["not"]
    #     fluent_keywords = ["increase", "decrease", "set", "*", "/", ">", "<", ">=", "<=", "="]
    #     durative_keywords = ["at start", "at end", "over all"]
    #     effects = effects.replace(")", "").replace("(and ", "").replace("\n", " ")
    #     effects = effects.split("(")
    #     effects = list(filter(None, effects))
    #     effect_list = []
    #     variables = []
    #     not_list = [False for _ in range(len(effects))]
    #     for idx, eff in enumerate(effects):
    #         durative = self.check_substring(eff, durative_keywords)
    #         fluent = self.check_substring(eff, fluent_keywords)
    #         strips = self.check_substring(eff, strips_keywords)
    #         temp = eff.split(" ")
    #         temp = list(filter(None, temp))
    #         if temp:
    #             if durative:
    #                 pass
    #             elif fluent:
    #                 not_list[idx]
    #             elif strips:
    #                 not_list[idx] = "not"
    #             else:
    #                 effect_list.append(temp[0])
    #                 variables.append(" ".join(temp[1:]))
    #     effects = []
    #     for idx, var in enumerate(variables):
    #         if not_list[idx] != False:
    #             effects.append(Predicates(f"{not_list[idx]} ({effect_list[idx]}", self.parameter_breakdown(var, True)))
    #         else:
    #             effects.append(Predicates(effect_list[idx], self.parameter_breakdown(var, True)))
    #     return effects
    
    def check_substring(self, string, substrings):
        for sub in substrings:
            if sub in string and "?" not in string:
                return True
        return False
        
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
            format += ")"
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
            format += f"({precond.name} {' '.join(['?'+key for key in precond.parameters])})"
        format += ")"
        return format
    
    def create_effects(self, effects):
        format = ":effect (and "
        for effect in effects:
            format += f"({effect.name} {' '.join(['?'+key+' ' for key in effect.parameters])})"
            if "not" in effect.name:
                format += ")"
        format += ")"
        return format
    
    def create_actions(self, actions):
        format = ""
        for action in actions:
            format += f"(:action {action.name}\n"
            format += f"    {self.create_parameters(action.parameters, for_action=True)}\n"
            format += f"    {self.create_preconditions(action.preconditions)}\n"
            format += f"    {self.create_effects(action.effects)}\n)\n"
        return format
        
    def create_domain(self):
        domain = "( define (domain " + self.domain_name + ")\n"
        if "requirements" in list(self.domain_components.keys()):
            domain += self.create_requirements(self.domain_components["requirements"])
        if "types" in list(self.domain_components.keys()):
            domain += self.create_types(self.domain_components["types"])
        if "constants" in list(self.domain_components.keys()):
            domain += self.create_constants(self.domain_components["constants"])
        if "predicates" in list(self.domain_components.keys()):
            domain += self.create_predicates(self.domain_components["predicates"])
        if "functions" in list(self.domain_components.keys()):
            domain += self.create_functions(self.domain_components["functions"])
        if "actions" in list(self.domain_components.keys()):
            domain += self.create_actions(self.domain_components["actions"])
        domain += ")"
        return domain

            
        
parser = DomainParser("data/IPC3/Tests1/Depots/Time/DepotsTime.pddl")
loaded = parser.load_domain()
if loaded:
    parser.breakdown_domain()
    print("hello")
else:
    print("Domain not loaded")