import pygame
import sys

# Initialize Pygame
pygame.init()

# Constants
WIDTH, HEIGHT = 800, 600
GRID_SIZE = 20
CELL_SIZE = (WIDTH - 200) // GRID_SIZE  # Adjust grid cell size to fill space
INFO_WIDTH = 200  # Width of the sidebar for state and objects
STATE_AREA_HEIGHT = 100  # Space for displaying states

# Colors
GREEN = (0, 255, 0)
BLUE = (0, 0, 255)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

# Screen setup
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Grid World Task Game")

# Fonts
font = pygame.font.Font(None, 24)

# Grid and objects setup
grid = [[False for _ in range(GRID_SIZE)] for _ in range(GRID_SIZE)]  # False initially, set to True for valid locations
objects = {}  # key: (x, y), value: list of objects
states = {}
agent_position = (0, 0)
inventory = []

def draw_grid():
    for x in range(GRID_SIZE):
        for y in range(GRID_SIZE):
            rect = pygame.Rect(x * CELL_SIZE, y * CELL_SIZE, CELL_SIZE, CELL_SIZE)
            pygame.draw.rect(screen, GREEN if grid[x][y] else WHITE, rect)
            pygame.draw.rect(screen, BLACK, rect, 1)  # Draw black border for each cell

def draw_agent():
    x, y = agent_position
    pygame.draw.circle(screen, BLUE, (x * CELL_SIZE + CELL_SIZE // 2, y * CELL_SIZE + CELL_SIZE // 2), CELL_SIZE // 3)

def draw_sidebar():
    sidebar = pygame.Rect(WIDTH - INFO_WIDTH, 0, INFO_WIDTH, HEIGHT)
    pygame.draw.rect(screen, BLACK, sidebar)  # Draw sidebar background
    # Draw state info
    state_text = f"States: {states}"
    state_surface = font.render(state_text, True, WHITE)
    screen.blit(state_surface, (WIDTH - INFO_WIDTH + 5, 5))
    # Draw objects at the current location
    if agent_position in objects:
        for index, obj in enumerate(objects[agent_position]):
            obj_text = f"{obj['name']} - Click to interact"
            obj_surface = font.render(obj_text, True, WHITE)
            screen.blit(obj_surface, (WIDTH - INFO_WIDTH + 5, 30 + index * 20))

def handle_movement(key):
    x, y = agent_position
    if key == pygame.K_LEFT and x > 0 and grid[x-1][y]:
        return (x-1, y)
    if key == pygame.K_RIGHT and x < GRID_SIZE - 1 and grid[x+1][y]:
        return (x+1, y)
    if key == pygame.K_UP and y > 0 and grid[x][y-1]:
        return (x, y-1)
    if key == pygame.K_DOWN and y < GRID_SIZE - 1 and grid[x][y+1]:
        return (x, y+1)
    return (x, y)

def handle_object_interaction(pos):
    x, y = pos
    sidebar_start = WIDTH - INFO_WIDTH
    if x >= sidebar_start:
        # Calculate which object (if any) was clicked
        obj_index = (y - 30) // 20
        if 0 <= obj_index < len(objects.get(agent_position, [])):
            # Add logic for object interaction
            print(f"Object {objects[agent_position][obj_index]['name']} clicked")

def main():
    running = True
    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.KEYDOWN:
                agent_position = handle_movement(event.key)
            elif event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:  # Left click
                    handle_object_interaction(event.pos)

        screen.fill(WHITE)
        draw_grid()
        draw_agent()
        draw_sidebar()
        pygame.display.flip()

    pygame.quit()
    sys.exit()

if __name__ == "__main__":
    main()
