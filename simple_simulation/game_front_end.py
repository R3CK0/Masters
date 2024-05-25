from dataclasses import dataclass
import pygame
import sys
import json
import os

# Initialize Pygame
pygame.init()

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
        self. BLACK = (0, 0, 0)

        # Screen setup
        self.screen = pygame.display.set_mode((self.WIDTH, self.HEIGHT))
        pygame.display.set_caption("Grid World Task Game")

        # Fonts
        self.font = pygame.font.Font(None, 24)

        # Grid and objects setup
        self.grid = [[False for _ in range(self.GRID_SIZE)] for _ in range(self.GRID_SIZE)]  # False initially, set to True for valid locations
        self.locations = {}
        self.objects = {}
        self.states = {}
        self.agents = {"BOB": Agent()}
        self.default_name = "BOB"
        self.start = False
        

    def update_congiguration(self):
        try:
            config = json.load(open("game_config.json"))
            locations = config["locations"]
            states = config["states"]
            objects = config["objects"]
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
                else:
                    new_state = State(name = state, type = states[state]["type"], value = states[state]["value"], possible_states = states[state]["states"])    
                    self.states[new_state.name] = new_state

            for obj in objects.keys():
                coord = (int(locations[objects[obj]["location"]]["coords"][0]), int(locations[objects[obj]["location"]]["coords"][1]))
                new_object = Object(name = obj, location = objects[obj]["location"], coords = coord, movable = objects[obj]["movable"], 
                                    consumed = objects[obj]["consumed"], effects = objects[obj]["effects"])
                self.objects[obj] = new_object

        except:
            print(f"Unable to load game_config.json file. Please check the file and try again. current working directory: {os.getcwd()}")

    def draw_grid(self):
        for x in range(self.GRID_SIZE):
            for y in range(self.GRID_SIZE):
                rect = pygame.Rect(x * self.CELL_SIZE, y * self.CELL_SIZE, self.CELL_SIZE, self.CELL_SIZE)
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
        state_text_lines = ["States:"] + [f"{state}: {str(value.value)}" for state, value in self.states.items()]
        for line in state_text_lines:
            state_surface = self.font.render(line, True, self.WHITE)
            self.screen.blit(state_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
            y_position += line_height  # Move down to draw the next line


        # Draw objects at the current location
        if self.get_agent_coords() in [obj.coords for obj in self.objects.values()]:
            location_objects = [obj.name for obj in self.objects.values() if self.objects[obj.name].coords == self.get_agent_coords()]
            for obj in location_objects:
                obj_text = f"{obj} - Available"
                obj_surface = self.font.render(obj_text, True, self.WHITE)
                self.screen.blit(obj_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
                y_position += line_height  # Increment for the next item or text line

    def handle_mouse_click(self, pos):
        x, y = pos
        sidebar_start = self.WIDTH - self.INFO_WIDTH
        grid_click_x = x // self.CELL_SIZE
        grid_click_y = y // self.CELL_SIZE

        if x < sidebar_start:  # Ensure click is within the grid area
            if self.grid[grid_click_x][grid_click_y]:  # Check if the cell is a valid location
                location = self.get_location_from_position((grid_click_x, grid_click_y))
                self.move_agent(location)
            else:
                print("Invalid location")
        # else:
        #     # Handle sidebar interactions if necessary
        #     if y > self.STATE_AREA_HEIGHT:  # Assuming interactions are below the state area
        #         obj_index = (y - self.STATE_AREA_HEIGHT) // 20
        #         if 0 <= obj_index < len(self.object_locations.get(self.get_agent_coords(), [])):
        #             # Add logic for object interaction
        #             print(f"Object {self.object_locations[self.get_agent_coords()][obj_index]['name']} clicked")
                    
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
        
    def pickup_object(self, object_name):
        if self.objects[object_name].location == self.agents[self.default_name].location:
            self.agents[self.default_name].inventory.append(self.objects[object_name])
            self.objects[object_name].location = "inventory"
            self.objects[object_name].coords = None
            
    def drop_object(self, object_name):
        if self.agents[self.default_name].inventory != []:
            if object_name in [objects.name for objects in self.agents[self.default_name].inventory]:
                self.agents[self.default_name].inventory = [objects for objects in self.agents[self.default_name].inventory if objects.name != object_name]
                self.objects[object_name].location = self.agents[self.default_name].location
                self.objects[object_name].coords = self.agents[self.default_name].coords
    
    
    # Potential object uses 
    # - Create
    # - Combine
    # - change_state
    # - destroy
    def use_object(self, object_name):
        consumed = self.objects[object_name].consumed
        effects = self.objects[object_name].effects
        
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
            elif effect.split(" ")[0] == "Destroy":
                self.destroy_object(effect)
            
            else:
                print(f"Invalid effect (ignoring): {effect}")
        
        if consumed:
            self.consume_object(object_name)
            
        
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
        
        self.objects[object_name] = Object(name = object_name, location = location, coords = coords, movable = movable, consumed = consumed, effects = effects)
    
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
            self.states[state].value = str(int(self.states[state]["value"]) + int(amount))
        
        elif change == "Decrease":
            state = " ".join(tokens[1: tokens.index("by")])
            amount = tokens[tokens.index("by")+1]
            self.states[state].value = str(int(self.states[state]["value"]) - int(amount))
            
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
            
            

    def main(self):
        running = True
        while running:
            if self.start:
                for event in pygame.event.get():
                    if event.type == pygame.QUIT:
                        running = False
                    elif event.type == pygame.MOUSEBUTTONDOWN:
                        if event.button == 1:  # Left click
                            self.handle_mouse_click(event.pos)
            else:
                self.update_congiguration()
            self.screen.fill(self.WHITE)
            self.draw_grid()
            self.draw_agent()
            self.draw_sidebar()
            pygame.display.flip()

        pygame.quit()
        sys.exit()

if __name__ == "__main__":
    game = PlanningSim()
    game.main()
