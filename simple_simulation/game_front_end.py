import pygame
import sys
import json

# Initialize Pygame
pygame.init()


class PlanningSim:

    def __init__(self):      
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
        for x, y in list(self.locations.values()):
            self.grid[x][y] = True
        self.objects = {}
        self.object_locations = {}  # key: object name, value: (x, y)
        self.states = {}
        self.agent_position = {"":(0, 0)}
        self.inventory = []
        self.start = False
        

    def update_congiguration(self):
        try:
            config = json.load(open("game_config.json"))
            locations = config["locations"]
            states = config["states"]
            objects = config["objects"]
            self.start = config["start"]

            for name in locations.keys():
                x, y = (locations[name]["coords"][0], locations[name]["coords"][1])
                self.grid[x][y] = True
                self.locations[name] = ((x, y))
                if locations[name]["agent_start"]:
                    self.agent_position = {name : (x, y)}

            for state in states.keys():
                if states[state]["type"] == "Boolean":
                    self.states[states[state]["name"]] = {"state_type":states[state]["type"], "value":states[state]["value"]}
                else:    
                    self.states[states[state]["name"]] = {"state_type":states[state]["type"], "possible_states": states[state]["states"], "value":states[state]["value"]}

            for obj in objects.keys():
                self.objects[obj] = {"location": (locations[objects[obj]["location"]]["coords"][0], locations[objects[obj]["location"]]["coords"][1]), "movable": objects[obj]["movable"], "consumed": objects[obj]["consumed"], "effects": objects[obj]["effects"]}
                self.object_locations[obj] = (locations[objects[obj]["location"]]["coords"][0], locations[objects[obj]["location"]]["coords"][1])
        except:
            print("Unable to load game_config.json file. Please check the file and try again.")

    def draw_grid(self):
        for x in range(self.GRID_SIZE):
            for y in range(self.GRID_SIZE):
                rect = pygame.Rect(x * self.CELL_SIZE, y * self.CELL_SIZE, self.CELL_SIZE, self.CELL_SIZE)
                pygame.draw.rect(self.screen, self.GREEN if self.grid[x][y] else self.WHITE, rect)
                pygame.draw.rect(self.screen, self.BLACK, rect, 1)  # Draw black border for each cell

    def draw_agent(self):
        x, y = self.get_agent_position()
        pygame.draw.circle(self.screen, self.BLUE, (x * self.CELL_SIZE + self.CELL_SIZE // 2, y * self.CELL_SIZE + self.CELL_SIZE // 2), self.CELL_SIZE // 3)

    def draw_sidebar(self):
        sidebar = pygame.Rect(self.WIDTH - self.INFO_WIDTH, 0, self.INFO_WIDTH, self.HEIGHT)
        pygame.draw.rect(self.screen, self.BLACK, sidebar)  # Draw sidebar background

        # Variables to control the layout
        x_margin = 5
        y_position = 5
        line_height = 20  # Adjustable based on font size and desired spacing

        # Draw state info
        state_text_lines = ["States:"] + [f"{state}: {value['value']}" for state, value in self.states.items()]
        for line in state_text_lines:
            state_surface = self.font.render(line, True, self.WHITE)
            self.screen.blit(state_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
            y_position += line_height  # Move down to draw the next line


        # Draw objects at the current location
        if self.get_agent_position() in self.object_locations.values():
            location_objects = [obj for obj in self.object_locations if self.object_locations[obj] == self.get_agent_position()]
            usable_objects = [self.objects[obj] for obj in location_objects]
            for obj in location_objects:
                obj_text = f"{obj} - Available Objects"
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
        else:
            # Handle sidebar interactions if necessary
            if y > self.STATE_AREA_HEIGHT:  # Assuming interactions are below the state area
                obj_index = (y - self.STATE_AREA_HEIGHT) // 20
                if 0 <= obj_index < len(self.object_locations.get(self.get_agent_position(), [])):
                    # Add logic for object interaction
                    print(f"Object {self.object_locations[self.get_agent_position()][obj_index]['name']} clicked")
                    
    def get_location_from_position(self, position):
        for location, coords in self.locations.items():
            if coords == position:
                return location
        return None
    
    def get_agent_position(self):
        return list(self.agent_position.values())[0]
    
    #Agent actions
    
    def move_agent(self, location):
        x, y = self.locations[location]
        self.agent_position = {location : (x, y)}
        
    def pickup_object(self, object_name):
        if self.objects[object_name]["location"] == self.agent_position:
            self.inventory.append(object_name)
            self.object_locations[object_name] = None
            
    def drop_object(self, object_name):
        if object_name in self.inventory:
            self.inventory.remove(object_name)
            self.object_locations[object_name] = self.get_agent_position()
    
    
    # Potential object uses 
    # - Create
    # - Combine
    # - change_state
    # - destroy
    def use_object(self, object_name):
        consumed = self.objects[object_name]["consumed"]
        effects = self.objects[object_name]["effects"]
        
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
            location = list(self.agent_position.keys())[0]
        else:
            location = " ".join(tokens[tokens.index("location")+1: tokens.index("is")])
        movable = True if tokens[tokens.index("movable")+2] == "True" else False
        consumed = True if tokens[tokens.index("consumed")+2] == "True" else False
        effects = " ".join(tokens[tokens.index("effects")+2:]).split(",")
        
        self.objects[object_name] = {"location": self.locations[location], "movable": movable, "consumed": consumed, "effects": effects}
        self.object_locations[object_name] = self.locations[location]
    
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
            self.states[state]["value"] = str(int(self.states[state]["value"]) + int(amount))
        
        elif change == "Decrease":
            state = " ".join(tokens[1: tokens.index("by")])
            amount = tokens[tokens.index("by")+1]
            self.states[state]["value"] = str(int(self.states[state]["value"]) - int(amount))
            
        elif change == "Set":
            state = " ".join(tokens[1: tokens.index("to")])
            value = tokens[tokens.index("to")+1]
            self.states[state]["value"] = value
        
        elif change == "Toggle":
            state = " ".join(tokens[1:])
            if self.states[state]["value"] == "True":
                self.states[state]["value"] = "False"
            else:
                self.states[state]["value"] = "True"
        
        elif change == "Rotate":
            state = " ".join(tokens[1:])
            current_state = self.states[state]["value"]
            states = self.states[state]["possible_states"]
            index = states.index(current_state)
            if index == len(states)-1:
                self.states[state]["value"] = states[0]
            else:
                self.states[state]["value"] = states[index+1]
    
    def destroy_object(self, effect):
        tokens = effect.split(" ")
        object_name = " ".join(tokens[1:])
        self.consume_object(object_name)
        
    
    def consume_object(self, object_name):
        try:
            self.inventory.remove(object_name)
        except:
            print(f"Object {object_name} not found in inventory")
        try:
            self.object_locations.pop(object_name)
        except:
            print(f"Object {object_name} not found")
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
