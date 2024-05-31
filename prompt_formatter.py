import json
from dataclasses import dataclass

# This class loads the json file containing the modification for the domain as well 
# as the domain and any usefull pddl examples. The returns a prompt ready to be used 
# to get the new modified domain

@dataclass
class Object:
    name: str
    movable: bool
    consumed: bool
    requires_states: dict
    requires_objects: list
    required_location: str  
    effect1: str
    effect2: str
    create_object: list
    delete: list
    state: list
    set_value: list
    toggle: list
    amount: list
    
@dataclass
class State:
    name: str
    value: str
    value_type: str
    max_value: str = None
    min_value: str = None
    
@dataclass
class Environment:
    locations: list
    states: dict
    objects: dict


class PromptFormatter:
    
    def __init__(self, environement_path: str, domain_path: str, pddl_examples_path: str = None) -> None:
        self.environement_path = environement_path
        self.pddl_examples_path = pddl_examples_path
        self.domain_path = domain_path
        self.loaded_environement = None
        self.environement = None
        self.pddl_examples = None
        self.domain = None
        self.temporaty_objects = {}
        self.load_files()
        
    def load_files(self) -> None:
        try:
            with open(self.environement_path) as f:
                self.loaded_environement = json.load(f)
        except:
            raise FileNotFoundError("Could not load the environement")
        try:
            with open(self.pddl_examples_path) as f:
                self.pddl_examples = json.load(f)
        except:
            print("No PDDL examples where loaded")
            pass
        try:
            with open(self.domain_path) as f:
                self.domain = f.read()
        except:
            raise FileNotFoundError("Could not load the domain")
        
        self.process_environement()
    
    def process_environement(self) -> None:
        locations = list(self.loaded_environement['locations'].keys())
        states = self.loaded_environement['states']
        objects = self.loaded_environement['objects']
        
        env_states = {}
        for state in list(states.values()):
            state_name = state["name"]
            state_type = state["type"]
            if state_type == "Boolean":
                state_value = state["value"]
                new_state = State(state_name, state_value, state_type)
            elif state_type == "Discrete":
                state_value = state["value"]
                new_state = State(state_name, state_value, state_type)
            elif state_type == "Range":
                state_value = state["value"]
                values = [int(value) for value in state["states"]]
                max_value = max(values)
                min_value = min(values)
                new_state = State(state_name, state_value, state_type, str(max_value), str(min_value))
            env_states[state_name] = new_state
        
        env_objects = {}
        for object_name, object in objects.items():
            movable = object["movable"]
            consumed = object["consumed"]
            requires_states = object["requires_states"]
            requires_objects = object["requires_objects"]
            required_location = object["required_location"]
            effect1 = object["effects"][0].split(" ")[0]
            effect2 = object["effects"][1].split(" ")[0]
            if effect2 not in ["Create", "Combine", "Set", "Rotate", "Increase", "Decrease", "Delete", "Toggle"]:
                effect2 = None
            if effect1 not in ["Create", "Combine", "Set", "Rotate", "Increase", "Decrease", "Delete", "Toggle"]:
                effect1 = None
            create_object = [None, None]
            state = [None, None]
            value = [None, None]
            amount = [None, None]
            delete = [None, None]
            toggle = [None, None]
            for idx, effect in enumerate([effect1, effect2]):
                if effect is not None:
                    tokens = object["effects"][idx].split(" ")
                    if effect == "Create":
                        create_object[idx] = " ".join(tokens[1: tokens.index("at")])
                        self.add_effect_object(object["effects"][idx])
                    elif effect == "Set":
                        state[idx] = " ".join(tokens[1: tokens.index("to")])
                        value[idx] = tokens[-1]
                    elif effect == "Increase" or effect == "Decrease":
                        state[idx] = " ".join(tokens[1: tokens.index("by")])
                        amount[idx] = tokens[-1]
                    elif effect == "Delete":
                        delete[idx] = " ".join(tokens[1:])
                    elif effect == "Toggle":
                        toggle[idx] = " ".join(tokens[1:])

            new_object = Object(object_name, movable, consumed, requires_states, requires_objects, required_location, effect1, effect2, create_object, delete, state, value, toggle, amount)
            env_objects[object_name] = new_object
        
        self.environement = Environment(locations, env_states, env_objects)
        self.add_temporaty_objects()
    
    def add_effect_object(self, object) -> None:
        tokens = object.split(" ")
        object_name = " ".join(tokens[1:tokens.index("at")]) # captures all words between "Create" and "at"
        movable = True if tokens[tokens.index("movable")+2] == "True" else False
        consumed = True if tokens[tokens.index("consumed")+2] == "True" else False
        list_effects = " ".join(tokens[tokens.index("effects")+2:]).split(",")
        required_objects = " ".join(tokens[tokens.index("requires_objects")+2: tokens.index("requires_states")])
        required_states = " ".join(tokens[tokens.index("requires_states")+2: tokens.index("requires_location")])
        required_location = " ".join(tokens[tokens.index("requires_location")+2:])
        effects = [None, None]
        for idx, effect in enumerate(list_effects):
            if effect.split(" ")[0] not in ["Create", "Combine", "Set", "Rotate", "Increase", "Decrease", "Delete", "Toggle"]:
                effects[idx] = None
            else:
                effects[idx] = effect.split(" ")[0]
        create_object = [None, None]
        state = [None, None]
        value = [None, None]
        amount = [None, None]
        delete = [None, None]
        toggle = [None, None]
        for idx, effect in enumerate(effects):
            if effect is not None:
                tokens = list_effects[idx].split(" ")
                if effect == "Set":
                    state[idx] = " ".join(tokens[1: tokens.index("to")])
                    value[idx] = tokens[-1]
                elif effect == "Increase" or effect == "Decrease":
                    state[idx] = " ".join(tokens[1: tokens.index("by")])
                    amount[idx] = tokens[-1]
                elif effect == "Delete":
                    delete[idx] = " ".join(tokens[1:])
                elif effect == "Toggle":
                    toggle[idx] = " ".join(tokens[1:])

        self.temporaty_objects[object_name] = Object(object_name, movable, consumed, required_states, required_objects, required_location, effects[0], effects[1], create_object, delete, state, value, toggle, amount)        
    
    def add_temporaty_objects(self) -> None:
        for object in list(self.temporaty_objects.values()):
            self.environement.objects[object.name] = object
    
    def get_prompt(self, modification_type=None) -> str:
        """
        Returns a prompt for the user to modify the PDDL domain
        if a example file is passed at initialization, the modification type can be used to add a desired example type to the prompt
        """
        state_list = list(self.environement.states.keys())
        tool_list = list(self.environement.objects.keys())
        return self.prep_prompts(state_list, tool_list, modification_type)
    
    #add feature for incremental construction of the domain
    def prep_prompts(self, state_list, tool_list, modification_type) -> str:
        prompt = self.generate_environemental_prompt(state_list, tool_list)
        prompt += "\n\n"
        prompt += self.domain
        prompt += "\n\n"
        prompt += self.get_example(modification_type)
        prompt += "Tools cannot be locations. \nStates cannot be locations.\nFor any new actions you define start them with the 'USE_' token\nUse correct PDDL syntax and avoid negative preconditions.\nDO not use 'if' since it does not exist in PDDL \nRespond with only the modified PDDL domain"
        return prompt
    
    def get_example(self, example_type):
        if example_type is None:
            return ""
        return f"{example_type} example: \n{self.pddl_examples[example_type]}\n\n"
    
    def generate_environemental_prompt(self, state_list, tool_list):
        prompt = f"Modify the following PDDL to include the following:\n"
        prompt += f"State:\n"
        for state in state_list:
            prompt += f"- {state}\n"
        prompt += f"Tools:\n"
        for tool in tool_list:
            if self.environement.objects[tool].movable:
                prompt += f"- {tool} (movable)\n"
            else:
                prompt += f"- {tool}\n"
        prompt += f"Effects:\n"
        prompt += self.format_effects(tool_list)
        return prompt
        
        
    def format_effects(self, tool_list):
        prompt = ""
        for object in tool_list:
            if self.environement.objects[object].effect1 != None:    
                required_states = self.environement.objects[object].requires_states
                if required_states == "None":
                    required_states = None
                required_tools = self.environement.objects[object].requires_objects
                if required_tools == "None":
                    required_tools = None
                required_location = self.environement.objects[object].required_location
                if required_location == "None":
                    required_location = None
                
                if required_states == None and required_tools == None and required_location == None:
                    pass
                else:
                    prompt += f"Using {object} requires "
                    if required_states != None:
                        for state, value in required_states.items():
                            prompt += f"{state} value to be {value}, "
                    if required_tools != None:
                        prompt +=f"{object} must be in the same location as the agent and "
                        for tool in required_tools:
                            prompt += f"{tool}, "
                    if required_location != None:
                        prompt += f"{object} must be in a valid location to be used."
                    prompt += "\n"
                
                prompt += f"Using {object} "
                
                effect_1_type = self.environement.objects[object].effect1
                effect_2_type = self.environement.objects[object].effect2

                for idx, effect_type in enumerate([effect_1_type, effect_2_type]):
                    if idx == 1 and effect_type != None:
                        prompt += "and "
                    if effect_type == "Create":
                        # Instantiate an object by moving it from an unreachble location to the current agent location
                        prompt += f"sets the location of {self.environement.objects[object].create_object[idx]} to the location of the {object}\n"
                    elif effect_type == "Delete":
                        prompt += f"sets the {self.environement.objects[object].delete[idx]} object to be unreachable.\n"
                    elif effect_type == "Set":
                        prompt += f"sets the value of {self.environement.objects[object].state[idx]} to {self.environement.objects[object].set_value[idx]}.\n"
                    elif effect_type == "Rotate":
                        prompt += f"sets the given {self.environement.objects[object].state[idx]} as the current {self.environement.objects[object].state[idx]}\n"
                    elif effect_type == "Increase":
                        prompt += f"increases the {self.environement.objects[object].state[idx]} state by a {self.environement.objects[object].amount[idx]} up to a maximum of {self.environement.states[self.environement.objects[object].state[idx]].max_value}\n"
                    elif effect_type == "Decrease":
                        prompt += f"decreases the {self.environement.objects[object].state[idx]} state by a {self.environement.objects[object].amount[idx]} up to a minimum of {self.environement.objects[self.environement.objects[object].state[idx]].min_value}\n"
                    elif effect_type == "Toggle":
                        prompt += f"toggles the {self.environement.objects[object].toggle[idx]} state between true and false\n"
                        
            if self.environement.objects[object].consumed:
                prompt += f"Using the {object} sets itself as unreachable.\n"
            
        return prompt

    
    # Step #1 Evaluate ability to recomplete domains from single prompt vs. Leveraging multiple prompts (Measured by successfull plan generation)
    # Step #2 Evaluate both methods in generating codebase aware domains (Logistics)(Rover)(tyreworld)(woodworking)(Measured by successfull plan generation) (Measured by successfull plan execution)
    # Step #3 Evaluate methods in deployement on robotics plateform (SPOT)(JACKAL)(Measured by successfull plan execution)
    
    # Step 1 methodology remove some actions, and states, leaving a valid subset of the domain. 
    #   - Evaluate how many interactions required in regular method (Lin Guan)
    #   - Evaluate how many interactions required with our method (no expert)
    
    # Step 2 methodology
    #  - Evaluate how many interactions are needed to write a domain that considers the codebase
    #  - Evaluate how many interactions are needed to write a domain with codebase awareness (no expert)
    
    # Step 3 methodology
    #  - Evaluate executability of the final plan on real world robotics plateform

