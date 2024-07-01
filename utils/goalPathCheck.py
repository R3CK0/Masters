

class PredicateDependencyGraph:
    def __init__(self):
        self.graph = {}
    
    def add_node(self, node):
        if node not in self.graph:
            self.graph[node] = []

    def add_edge(self, from_node, to_node):
        self.add_node(from_node)
        self.add_node(to_node)
        self.graph[from_node].append(to_node)

    def build_graph(self, domain):
        for action in domain['actions']:
            for precondition in action['preconditions']:
                self.add_edge(precondition, action['name'])
            for effect in action['effects']:
                self.add_edge(action['name'], effect)

    def is_predicate_reachable(self, initial_state, goal_predicate):
        visited = set()

        def dfs(node):
            if node in visited:
                return False
            visited.add(node)
            if node == goal_predicate:
                return True
            for neighbor in self.graph.get(node, []):
                if dfs(neighbor):
                    return True
            return False

        for initial_predicate in initial_state:
            if dfs(initial_predicate):
                return True
        return False