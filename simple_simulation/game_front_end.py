from dataclasses import dataclass
import pygame
import sys
import json
import os

# Initialize Pygame
#pygame.init()

@dataclass
class Location:
    name: str
    coords: tuple
    agent_start: bool

@dataclass
class Object:
    name: str
    location: str
    coords: tuple
    movable: bool
    consumed: bool
    effects: list
    required_location: str = None
    required_objects: list = None
    required_states: dict = None

@dataclass
class State:
    name: str
    type: str
    value: str
    possible_states: list

@dataclass   
class Agent:
    name = "BOB"
    location = ""
    coords = (0, 0)
    inventory = []


class PlanningSim:

    def __init__(self, config_path = "game_config.json"):
        #config path
        self.config_path = config_path
              
        # Constants
        self.WIDTH, self.HEIGHT = 1000, 600
        self.GRID_SIZE = 20
        self.CELL_SIZE = (self.WIDTH - 400) // self.GRID_SIZE  # Adjust grid cell size to fill space
        self.INFO_WIDTH = 400  # Width of the sidebar for state and objects
        self.STATE_AREA_HEIGHT = 200  # Space for displaying states

        # Colors
        self.GREEN = (0, 255, 0)
        self.BLUE = (0, 0, 255)
        self.WHITE = (255, 255, 255)
        self.BLACK = (0, 0, 0)
        self.ORANGE = (255, 165, 0)

        # Screen setup
        self.screen = pygame.display.set_mode((self.WIDTH, self.HEIGHT))
        pygame.display.set_caption("Grid World Task Game")

        # Fonts
        self.font = pygame.font.Font(None, 24)

        # Grid and objects setup
        self.grid = [[False for _ in range(self.GRID_SIZE)] for _ in range(self.GRID_SIZE)]  # False initially, set to True for valid locations
        self.locations = {}
        self.object_types = {}
        self.objects = {}
        self.states = {}
        self.agents = {"BOB": Agent()}
        self.default_name = "BOB"
        self.start = False
        self.running = False

        self.selected_cell = None
        self.select_objects = False
        self.select_inventory = False
        self.selected_item_pos = 0
        self.selected_item = None
        

    def update_congiguration(self):
        try:
            config = json.load(open(self.config_path))
            locations = config["locations"]
            states = config["states"]
            objects = config["objects"]
            elements = config["elements"]
            self.start = config["start"]

            for name in locations.keys():
                x, y = (int(locations[name]["coords"][0]), int(locations[name]["coords"][1]))
                self.grid[x][y] = True
                self.locations[name] = Location(name = name, coords = (x, y), agent_start = locations[name]["agent_start"])
                if self.locations[name].agent_start:
                    self.agents[self.default_name].location = name
                    self.agents[self.default_name].coords = (x, y)
                
            for state in states.keys():
                if states[state]["type"] == "Boolean":
                    new_state = State(name = state, type = states[state]["type"], value = states[state]["value"], possible_states = [True, False])
                    self.states[new_state.name] = new_state
                elif states[state]["type"] == "Predicate":
                    new_state = State(name = state, type = states[state]["type"], value = states[state]["value"], possible_states = states[state]["states"])
                    self.states[new_state.name] = new_state
                else:
                    new_state = State(name = state, type = states[state]["type"], value = states[state]["value"], possible_states = states[state]["states"])    
                    self.states[new_state.name] = new_state

            for obj in objects.keys():
                coord = (int(locations[objects[obj]["location"]]["coords"][0]), int(locations[objects[obj]["location"]]["coords"][1]))
                if objects[obj]["required_location"] == "None":
                    objects[obj]["required_location"] = None
                if objects[obj]["requires_objects"] == "None":
                    objects[obj]["requires_objects"] = None
                if objects[obj]["requires_states"] == "None":
                    objects[obj]["requires_states"] = None
                new_object = Object(name = obj, location = objects[obj]["location"], coords = coord, movable = objects[obj]["movable"], 
                                    consumed = objects[obj]["consumed"], effects = objects[obj]["effects"], required_location = objects[obj]["required_location"],
                                    required_states=objects[obj]["requires_states"], required_objects=objects[obj]["requires_objects"])
                self.object_types[obj] = new_object
                
            for element in elements.keys():
                coord = (int(locations[elements[element]["location"]]["coords"][0]), int(locations[elements[element]["location"]]["coords"][1]))
                new_object = Object(name = element, location = elements[element]["location"], coords = coord, movable = self.object_types[elements[element]["type"]].movable, 
                                    consumed = self.object_types[elements[element]["type"]].consumed, effects = self.object_types[elements[element]["type"]].effects, 
                                    required_location = self.object_types[elements[element]["type"]].required_location,
                                    required_states=self.object_types[elements[element]["type"]].required_states, required_objects=self.object_types[elements[element]["type"]].required_objects)
                self.objects[element] = new_object

                    

        except Exception as e:
            print(e)
            print(f"Unable to load {self.config_path} file. Please check the file and try again. current working directory: {os.getcwd()}")

    def draw_grid(self):
        for x in range(self.GRID_SIZE):
            for y in range(self.GRID_SIZE):
                rect = pygame.Rect(x * self.CELL_SIZE, y * self.CELL_SIZE, self.CELL_SIZE, self.CELL_SIZE)
                if self.selected_cell == (x, y):
                    pygame.draw.rect(self.screen, self.ORANGE, rect)
                else:
                    pygame.draw.rect(self.screen, self.GREEN if self.grid[x][y] else self.WHITE, rect)
                pygame.draw.rect(self.screen, self.BLACK, rect, 1)  # Draw black border for each cell

    def draw_agent(self):
        x, y = self.get_agent_coords()
        pygame.draw.circle(self.screen, self.BLUE, (x * self.CELL_SIZE + self.CELL_SIZE // 2, y * self.CELL_SIZE + self.CELL_SIZE // 2), self.CELL_SIZE // 3)

    def draw_sidebar(self):
        sidebar = pygame.Rect(self.WIDTH - self.INFO_WIDTH, 0, self.INFO_WIDTH, self.HEIGHT)
        pygame.draw.rect(self.screen, self.BLACK, sidebar)  # Draw sidebar background

        # Variables to control the layout
        x_margin = 5
        y_position = 5
        line_height = 20  # Adjustable based on font size and desired spacing

        # Draw state info
        state_text_lines = ["States:"] + ["============"] + [f"{state}: {str(value.value)}" for state, value in self.states.items() if value.type != "Predicate"]
        for line in state_text_lines:
            state_surface = self.font.render(line, True, self.WHITE)
            self.screen.blit(state_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
            y_position += line_height  # Move down to draw the next line


        # Draw objects at the current location
        obj_surface = self.font.render("Objects:", True, self.WHITE)
        self.screen.blit(obj_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
        y_position += line_height  # Increment for the next item or text line
        obj_surface = self.font.render("============", True, self.WHITE)
        self.screen.blit(obj_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
        y_position += line_height  # Increment for the next item or text line

        display_coords = (0,0)
        if self.selected_cell is not None:
            display_coords = self.selected_cell
        else:
            display_coords = self.get_agent_coords()
        if display_coords in [obj.coords for obj in self.objects.values()]:
            location_objects = [obj.name for obj in self.objects.values() if obj.coords == display_coords]
            for idx, obj in enumerate(location_objects):
                if self.objects[obj].movable:
                    obj_text = f"{obj} - Movable"
                else:
                    obj_text = f"{obj}"
                if self.select_objects:
                    if idx == self.selected_item_pos:
                        obj_text = f">> {obj_text} <<"
                if self.check_usable(obj):
                    obj_surface = self.font.render(obj_text, True, self.GREEN)
                else:
                    obj_surface = self.font.render(obj_text, True, self.WHITE)
                self.screen.blit(obj_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
                y_position += line_height  # Increment for the next item or text line
                
        # Draw agent inventory
        # Draw objects at the current location
        obj_surface = self.font.render("Inventory Objects:", True, self.WHITE)
        self.screen.blit(obj_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
        y_position += line_height  # Increment for the next item or text line
        obj_surface = self.font.render("============", True, self.WHITE)
        self.screen.blit(obj_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
        y_position += line_height  # Increment for the next item or text line

        if self.agents[self.default_name].inventory != []:
            inventory_objects = [obj.name for obj in self.agents[self.default_name].inventory]
            for idx, obj in enumerate(inventory_objects):
                obj_text = f"{obj} - (Inventory)"
                if self.select_inventory:
                    if idx == self.selected_item_pos:
                        obj_text = f">> {obj_text} <<"  
                if self.check_usable(obj):
                    obj_surface = self.font.render(obj_text, True, self.GREEN)
                else:        
                    obj_surface = self.font.render(obj_text, True, self.WHITE)
                self.screen.blit(obj_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
                y_position += line_height
                
    ######################################
    #Handling of keyboard and mouse events
    ######################################
    
    def get_clicked_location(self, pos):
        x, y = pos
        sidebar_start = self.WIDTH - self.INFO_WIDTH
        grid_click_x = x // self.CELL_SIZE
        grid_click_y = y // self.CELL_SIZE

        if x < sidebar_start:  # Ensure click is within the grid area
            if self.grid[grid_click_x][grid_click_y]:  # Check if the cell is a valid location
                self.selected_cell = (grid_click_x, grid_click_y)
                return self.get_location_from_position((grid_click_x, grid_click_y))
            else:
                return None
    
    def reset_selection(self):
        self.selected_cell = None
        self.select_objects = False
        self.select_inventory = False
        self.selected_item_pos = 0
        self.selected_item = None

    def object_selection(self):
        if self.selected_cell == None or self.selected_cell == self.get_agent_coords():
            if [obj.name for obj in self.objects.values() if obj.coords == self.get_agent_coords()] == []:
                print("No objects at this location to interact with")
            else:
                self.select_objects = True
                self.select_inventory = False
        else:
            print("You must be at the agent's location to access the objects")
    
    def inventory_selection(self):
        if self.selected_cell == None or self.selected_cell == self.get_agent_coords():
            if self.agents[self.default_name].inventory == []:
                print("No objects in inventory to interact with")
            else:
                self.select_inventory = True
                self.select_objects = False
        else:
            print("You must be at the agent's location to access the inventory")
    
    def select_next_item(self):
        if self.select_objects:
            if self.selected_item_pos == len([obj for obj in self.objects.values() if obj.coords == self.get_agent_coords()]) - 1:
                self.selected_item_pos = 0
            else:
                self.selected_item_pos += 1
        elif self.select_inventory:
            if self.selected_item_pos == len(self.agents[self.default_name].inventory) - 1:
                self.selected_item_pos = 0
            else:
                self.selected_item_pos += 1

        self.selected_item = self.get_selected_item()
    
    def select_previous_item(self):
        if self.select_objects:
            if self.selected_item_pos == 0:
                self.selected_item_pos = len([obj for obj in self.objects.values() if obj.coords == self.get_agent_coords()]) - 1
            else:
                self.selected_item_pos -= 1
        elif self.select_inventory:
            if self.selected_item_pos == 0:
                self.selected_item_pos = len(self.agents[self.default_name].inventory) - 1
            else:
                self.selected_item_pos -= 1

        self.selected_item = self.get_selected_item()
    
    def get_selected_item(self):
        if self.select_objects:
            return [obj for obj in self.objects.values() if obj.coords == self.get_agent_coords()][self.selected_item_pos].name
        elif self.select_inventory:
            return self.agents[self.default_name].inventory[self.selected_item_pos].name
                    
    def get_location_from_position(self, position):
        for location_name, loc in self.locations.items():
            if loc.coords == position:
                return location_name
        return None
    
    def get_agent_coords(self):
        return self.agents[self.default_name].coords
    
    #Agent actions
    
    def move_agent(self, location_name):
        self.agents[self.default_name].coords = self.locations[location_name].coords
        self.agents[self.default_name].location = location_name
        
    def pickup_object(self, object_name):
        if self.objects[object_name].location == self.agents[self.default_name].location:
            if self.objects[object_name].movable:
                self.agents[self.default_name].inventory.append(self.objects[object_name])
                self.objects[object_name].location = "inventory"
                self.objects[object_name].coords = None
            
    def drop_object(self, object_name):
        if self.agents[self.default_name].inventory != []:
            if object_name in [objects.name for objects in self.agents[self.default_name].inventory]:
                self.agents[self.default_name].inventory = [objects for objects in self.agents[self.default_name].inventory if objects.name != object_name]
                self.objects[object_name].location = self.agents[self.default_name].location
                self.objects[object_name].coords = self.agents[self.default_name].coords
    
    def check_usable(self, object_name, verbose=False):
        usable = True
        required_location = self.objects[object_name].required_location
        required_objects = self.objects[object_name].required_objects
        required_states = self.objects[object_name].required_states
        
        if required_location is not None:
            inventory = [obj.name for obj in self.agents[self.default_name].inventory]
            if object_name in inventory:
                if required_location != self.agents[self.default_name].location:
                    usable = False
                    if verbose:
                        print(f"Object {object_name} cannot be used at this location")
            elif required_location != self.objects[object_name].location:
                usable = False
                if verbose:
                    print(f"Object {object_name} cannot be used at this location")
        
        if required_objects is not None:
            for obj in required_objects:
                if obj not in [objects.name for objects in self.agents[self.default_name].inventory] and obj not in [objects.name for objects in list(self.objects.values()) if objects.location == self.objects[object_name].location]:
                    usable = False
                    if verbose:
                        print(f"Object {object_name} cannot be used without {obj} present")
        
        if required_states is not None:
            for state, value in required_states.items():
                if self.states[state].type == "Predicate":
                    if len(value) > 1:
                        for val in value:
                            if val not in self.states[state].value:
                                usable = False
                                if verbose:
                                    print(f"Object {object_name} does not meet the required predicate {state} value {val}")
                    elif value[0] not in self.states[state].value:
                        usable = False
                        if verbose:
                            print(f"Object {object_name} does not meet the required predicate {state} value {value}")
                elif value.startswith(">="):
                    if int(self.states[state].value) < int(value.replace(">=", "")):
                        usable = False
                        if verbose:
                            print(f"Object {object_name} cannot be used without state {state} being greater than {value[1:]}")
                elif value.startswith("<="):
                    if int(self.states[state].value) > int(value.replace("<=", "")):
                        usable = False
                        if verbose:
                            print(f"Object {object_name} cannot be used without state {state} being less than {value[1:]}")
                elif value.startswith(">"):
                    if int(self.states[state].value) <= int(value.replace(">", "")):
                        usable = False
                        if verbose:
                            print(f"Object {object_name} cannot be used without state {state} being greater than {value}")
                elif value.startswith("<"):
                    if int(self.states[state].value) >= int(value.replace("<", "")):
                        usable = False
                        if verbose:
                            print(f"Object {object_name} cannot be used without state {state} being less than {value}")
                elif self.states[state].value != value:
                        usable = False
                        if verbose:
                            print(f"Object {object_name} cannot be used without state {state} being {value}")
        
        return usable
    
    
    # Potential object uses 
    # - Create
    # - Combine
    # - change_state
    # - destroy
    def use_object(self, object_name):
        if object_name is not None:
            consumed = self.objects[object_name].consumed
            effects = self.objects[object_name].effects
            
            if self.check_usable(object_name, verbose=True):
                for effect in effects:
                    
                    # Create effect handle
                    if effect.split(" ")[0] == "Create":
                        self.create_object(effect)
                                
                    # Combine effect handle
                    elif effect.split(" ")[0] == "Combine":
                        self.combine_objects(effect)
                    
                    # Change state effect handle
                    elif effect.split(" ")[0] == "Increase" or effect.split(" ")[0] == "Decrease" or effect.split(" ")[0] == "Set" or effect.split(" ")[0] == "Toggle" or effect.split(" ")[0] == "Rotate":
                        self.state_change(effect)
                    
                    # Destroy effect handle
                    elif effect.split(" ")[0] == "Delete":
                        self.destroy_object(effect)
                    
                    else:
                        print(f"Invalid effect (ignoring): {effect}")
                
                if consumed:
                    self.consume_object(object_name)
        else:
            print("No object selected")

            
        
    # Effect handlers
    # Create
    def create_object(self, effect, agent_location=False):
        tokens = effect.split(" ")
        object_name = " ".join(tokens[1:tokens.index("at")]) # captures all words between "Create" and "at"
        if agent_location:
            location = self.agents[self.default_name].location
            coords = self.agents[self.default_name].coords
        else:
            location = " ".join(tokens[tokens.index("location")+1: tokens.index("is")])
            coords = self.locations[location].coords
        movable = True if tokens[tokens.index("movable")+2] == "True" else False
        consumed = True if tokens[tokens.index("consumed")+2] == "True" else False
        effects = " ".join(tokens[tokens.index("effects")+2:]).split(",")
        required_objects = " ".join(tokens[tokens.index("requires_objects")+2: tokens.index("requires_states")])
        required_states = " ".join(tokens[tokens.index("requires_states")+2: tokens.index("requires_location")])
        required_location = " ".join(tokens[tokens.index("requires_location")+2:])
        
        
        self.objects[object_name] = Object(name = object_name, location = location, coords = coords, movable = movable, consumed = consumed, effects = effects, required_location = required_location, required_objects = required_objects, required_states = required_states)
    
    #combine  
    def combine_objects(self, effect):
        tokens = effect.split(" ")
        object1 = " ".join(tokens[1:tokens.index("with")])
        object2 = " ".join(tokens[tokens.index("with")+1: tokens.index("create")])
        
        self.create_object(" ".join(tokens[tokens.index("create"):]), agent_location=True)
        self.consume_object(object1)
        self.consume_object(object2)
        
    
    def state_change(self, effect):
        tokens = effect.split(" ")
        change = tokens[0]
        
        if change == "Increase":
            state = " ".join(tokens[1: tokens.index("by")])
            amount = tokens[tokens.index("by")+1]
            self.states[state].value = str(int(self.states[state].value) + int(amount))
        
        elif change == "Decrease":
            state = " ".join(tokens[1: tokens.index("by")])
            amount = tokens[tokens.index("by")+1]
            self.states[state].value = str(int(self.states[state].value) - int(amount))
            
        elif change == "Set":
            state = " ".join(tokens[1: tokens.index("to")])
            value = tokens[tokens.index("to")+1]
            self.states[state].value = value
        
        elif change == "Toggle":
            state = " ".join(tokens[1:])
            if self.states[state].value:
                self.states[state].Value = False
            else:
                self.states[state].value = True
                
        elif change == "Rotate":
            state = " ".join(tokens[1:])
            current_state = self.states[state].value
            states = self.states[state].possible_states
            index = states.index(current_state)
            if index == len(states)-1:
                self.states[state].value = states[0]
            else:
                self.states[state].value = states[index+1]
                
        elif change == "Predicate": #TODO deal with predicate change
            pass
    
    def destroy_object(self, effect):
        tokens = effect.split(" ")
        object_name = " ".join(tokens[1:])
        self.consume_object(object_name)
        
    
    def consume_object(self, object_name):
        try:
            self.agents[self.default_name].inventory = [objects for objects in self.agents[self.default_name].inventory if objects.name != object_name]
        except:
            print(f"Object {object_name} not found in inventory")
        try:
            self.objects.pop(object_name)
        except:
            print(f"Object {object_name} not found")

    def get_events(self):
        return pygame.event.get()
            
    def init(self):
        self.running = True
        self.update_congiguration()
        if self.start:
            self.screen.fill(self.WHITE)
            self.draw_grid()
            self.draw_agent()
            self.draw_sidebar()
            pygame.display.flip()

    def update(self):
        pygame.time.wait(20)
        self.screen.fill(self.WHITE)
        self.draw_grid()
        self.draw_agent()
        self.draw_sidebar()
        pygame.display.flip()
        
    def exit(self):
        pygame.quit()
        sys.exit()
