from prompt_formatter import PromptFormatter

domain_path = "initial.pddl"
config_path = "open_world.json"
example_path = None

prompter = PromptFormatter(config_path, domain_path, example_path)
prompt = prompter.get_prompt()
print(prompt)

