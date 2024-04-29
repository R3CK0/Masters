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
        self.locations = []
        for x, y in self.locations:
            self.grid[x][y] = True
        self.objects = {}
        self.object_locations = {}  # key: object name, value: (x, y)
        self.states = {}
        self.agent_position = (0, 0)
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
                self.locations.append((x, y))
                if locations[name]["agent_start"]:
                    self.agent_position = (x, y)

            for state in states.keys():
                self.states[states[state]["name"]] = states[state]["value"]

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
        x, y = self.agent_position
        pygame.draw.circle(self.screen, self.BLUE, (x * self.CELL_SIZE + self.CELL_SIZE // 2, y * self.CELL_SIZE + self.CELL_SIZE // 2), self.CELL_SIZE // 3)

    def draw_sidebar(self):
        sidebar = pygame.Rect(self.WIDTH - self.INFO_WIDTH, 0, self.INFO_WIDTH, self.HEIGHT)
        pygame.draw.rect(self.screen, self.BLACK, sidebar)  # Draw sidebar background

        # Variables to control the layout
        x_margin = 5
        y_position = 5
        line_height = 20  # Adjustable based on font size and desired spacing

        # Draw state info
        state_text_lines = ["States:"] + [f"{state}: {value}" for state, value in self.states.items()]
        for line in state_text_lines:
            state_surface = self.font.render(line, True, self.WHITE)
            self.screen.blit(state_surface, (self.WIDTH - self.INFO_WIDTH + x_margin, y_position))
            y_position += line_height  # Move down to draw the next line


        # Draw objects at the current location
        if self.agent_position in self.object_locations.values():
            location_objects = [obj for obj in self.object_locations if self.object_locations[obj] == self.agent_position]
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
                self.agent_position = (grid_click_x, grid_click_y)
            else:
                print("Invalid location")
        else:
            # Handle sidebar interactions if necessary
            if y > self.STATE_AREA_HEIGHT:  # Assuming interactions are below the state area
                obj_index = (y - self.STATE_AREA_HEIGHT) // 20
                if 0 <= obj_index < len(self.object_locations.get(self.agent_position, [])):
                    # Add logic for object interaction
                    print(f"Object {self.object_locations[self.agent_position][obj_index]['name']} clicked")

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
