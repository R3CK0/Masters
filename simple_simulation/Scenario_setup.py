import tkinter as tk
from tkinter import ttk, messagebox, simpledialog
import json

#TODO Add a way to add preexisting objects
#TODO add a way to add actions that dont require objects (or that use the agent as an object)

class GameStateEditor:
    def __init__(self, root, setup_name):
        self.root = root
        self.root.title('Game State Editor')
        self.setup_name = setup_name

        # Containers
        self.frame = ttk.Frame(self.root, padding="3 3 12 12")
        self.frame.grid(column=0, row=0, sticky=(tk.N, tk.W, tk.E, tk.S))

        self.sidebar = ttk.Frame(self.root, padding="3 3 12 12", width=200)
        self.sidebar.grid(column=2, row=1, sticky=(tk.N, tk.W, tk.E, tk.S), rowspan=2)

        self.input_area = ttk.Frame(self.root, padding="3 3 12 12")
        self.input_area.grid(column=0, row=1, sticky=(tk.N, tk.W, tk.E, tk.S))

        self.input_area_2 = ttk.Frame(self.root, padding="3 3 12 12")
        self.input_area_2.grid(column=1, row=1, sticky=(tk.N, tk.W, tk.E, tk.S))

        self.input_area_3 = ttk.Frame(self.root, padding="3 3 12 12")
        self.input_area_3.grid(column=1, row=2, sticky=(tk.N, tk.W, tk.E, tk.S))

        # Variables for storing short term data
        self.name = None
        self.entry = None
        self.combo_selection = None
        self.predicate_vars = []
        self.entries = {}
        self.effects = {}
        self.location_combos = {}
        self.movable = {}
        self.consumed = {}
        self.requires_objects = {"main": [], "secondary": []}
        self.requires_states = {"main": {}, "secondary": {}}
        self.temp_required_state_value = None
        self.required_location = {"main": "None", "secondary": "None"}
        self.deletion = {}
        self.state_change = {"main": "None", "secondary": "None"}
        self.available_effects_1 = ["None", "Change State", "Create", "Combine", "Delete"]
        self.available_effects_2 = ["None", "Change State", "Create", "Combine", "Delete"]
        self.temporary_window = None

        # Data storage
        self.locations = {"Unreachable": {"coords":[-1,-1], "agent_start": False}}
        self.states = {}
        self.objects = {}
        self.elements = {}

        # Buttons
        ttk.Button(self.frame, text="Location", command=self.add_location_form).grid(column=0, row=0)
        ttk.Button(self.frame, text="State", command=self.add_state_form).grid(column=1, row=0)
        ttk.Button(self.frame, text="Object", command=self.add_object_form).grid(column=2, row=0)
        ttk.Button(self.frame, text="Save", command=lambda: self.save_configuration(True)).grid(column=3, row=0)
        ttk.Button(self.frame, text="Load", command=lambda: self.load_configuration()).grid(column=4, row=0)
        ttk.Button(self.frame, text="Generate PDDL", command=lambda: self.load_configuration()).grid(column=5, row=0)  # TODO implement
        ttk.Button(self.frame, text="Generate Prompt", command=lambda: self.load_configuration()).grid(column=6, row=0)  # TODO implement

        # Sidebar list
        self.sidebar_label = ttk.Label(self.sidebar, text="Current Configurations", font=('Arial', 12))
        self.sidebar_label.grid(column=0, row=0, sticky=(tk.W))
        self.listbox = tk.Listbox(self.sidebar, width=50, height=30)
        self.listbox.grid(column=0, row=1, sticky=(tk.N, tk.W, tk.E, tk.S))

    def clear_widgets(self):
        try:
            for widget in self.input_area.winfo_children():
                widget.destroy()
        except:
            print("error detected while closing input area 1")
        try:
            for widget in self.input_area_2.winfo_children():
                widget.destroy()
        except:
            print("error detected while closing input area 2")
        try:
            for widget in self.input_area_3.winfo_children():
                widget.destroy()
        except:
            print("error detected while closing input area 3")

    def reset_available_effects(self):
        self.available_effects_1 = ["None", "Change State", "Create", "Combine", "Delete"]
        self.available_effects_2 = ["None", "Change State", "Create", "Combine", "Delete"]


    def add_location_form(self):
        # Clear previous content
        self.clear_widgets()

        # Add new form fields
        ttk.Label(self.input_area, text="Location Name:").grid(row=0, column=0)
        name_entry = ttk.Entry(self.input_area)
        name_entry.grid(row=0, column=1)

        ttk.Label(self.input_area, text="X Coordinate:").grid(row=1, column=0)
        x_entry = ttk.Entry(self.input_area)
        x_entry.grid(row=1, column=1)

        ttk.Label(self.input_area, text="Y Coordinate:").grid(row=2, column=0)
        y_entry = ttk.Entry(self.input_area)
        y_entry.grid(row=2, column=1)

        agent_start_var = tk.BooleanVar()
        ttk.Checkbutton(self.input_area, text="Agent Start Position", variable=agent_start_var).grid(row=3, column=1)

        ttk.Button(self.input_area, text="Add Location", command=lambda: self.add_location(
            name_entry.get(), int(x_entry.get()), int(y_entry.get()), agent_start_var.get())).grid(row=4, column=1)
        
    def add_state_form(self):
        self.clear_widgets()
        ttk.Button(self.input_area, text="Add New State", command=self.add_new_state_form).grid(row=0, column=0)
        ttk.Button(self.input_area, text="Set Existing Predicate", command=self.set_existing_state).grid(row=1, column=0)
    
    def set_existing_state(self):
        self.clear_widgets()
        ttk.Label(self.input_area, text="Predicate:").grid(row=0, column=0)
        state_combo = ttk.Combobox(self.input_area, values=[state for state in list(self.states.keys()) if self.states[state]["type"] == "Predicate"])
        state_combo.grid(row=0, column=1)
        state_combo.bind("<<ComboboxSelected>>", lambda event: self.on_focus_out_entry(event, state_combo))
        ttk.Button(self.input_area, text="Set Predicate values", command=lambda: self.set_predicate(state_combo.get())).grid(row=1, column=1)
        
    def add_new_state_form(self):
        # Clear previous content
        self.clear_widgets()

        ttk.Label(self.input_area, text="State Name:").grid(row=0, column=0)
        name_entry = ttk.Entry(self.input_area)
        name_entry.grid(row=0, column=1)
        name = name_entry.bind("<FocusOut>", lambda event, e=name_entry: self.on_focus_out(event, e))

        ttk.Label(self.input_area, text="State Type:").grid(row=1, column=0)
        state_type = ttk.Combobox(self.input_area, values=["Boolean", "Range", "Predicate"])
        state_type.grid(row=1, column=1)

        state_type.bind("<<ComboboxSelected>>", lambda event, e=state_type: self.state_combo_update(event, e))
        
    def add_object_form(self):
        self.clear_widgets()
        
        ttk.Button(self.input_area, text="Add New Object", command=self.add_new_object).grid(row=0, column=0)
        ttk.Button(self.input_area, text="Add Existing Object", command=self.add_existing_object_form).grid(row=1, column=0)
        
    def add_existing_object_form(self):
        self.clear_widgets()
        
        ttk.Label(self.input_area, text="Object Name:").grid(row=0, column=0)
        name_entry = ttk.Entry(self.input_area)
        name_entry.grid(row=0, column=1)
        name_entry.bind("<FocusOut>", lambda event, e=name_entry: self.on_focus_out(event, e))
        
        ttk.Label(self.input_area, text="Location:").grid(row=1, column=0)
        self.location_combos["element"] = ttk.Combobox(self.input_area, values=list(self.locations.keys()))
        self.location_combos["element"].grid(row=1, column=1)
        
        ttk.Label(self.input_area, text="Object type").grid(row=2, column=0)
        self.combo_selection = ttk.Combobox(self.input_area, values=["Agent"]+list(self.objects.keys()))
        self.combo_selection.grid(row=2, column=1)
        ttk.Button(self.input_area, text="Add Object", command=lambda: self.process_extra_object()).grid(row=3, column=1)
        
    def add_new_object(self):
        self.clear_widgets()
        self.add_object()
        
    def set_predicate(self, state_name):
        if self.temporary_window is not None:
            try:
                self.temporary_window.destroy()
            except:
                print("temporary window does not exist or caused somekind of error")
            self.temporary_window = None
        self.temporary_window = tk.Toplevel(self.root, padx=20, pady=20)
        self.temporary_window.title("Set Predicate")
        ttk.Label(self.temporary_window, text=f"Set {state_name} Predicate").grid(row=0, column=0)
        objects = [] 
        for idx, parameter in enumerate(list(self.states[state_name]["states"])):
            element_list = []
            if parameter == "agent":
                element_list.append("agent")
            if parameter == "location":
                element_list += [name for name, value in self.locations.items()]
            else:    
                element_list += [name for name, value in self.elements.items() if value["type"] == parameter]
            ttk.Label(self.temporary_window, text=f"Select {parameter}").grid(row=1+idx, column=0)
            objects.append(ttk.Combobox(self.temporary_window, values=element_list))
            objects[idx].grid(row=1+idx, column=1)
            
        ttk.Button(self.temporary_window, text="Confirm selection", command=lambda: self.set_predicate_2(objects, state_name)).grid(row=len(list(self.states[state_name]["states"]))+1, column=1)

    def set_predicate_2(self, objects, state_name):
        object_list = [obj.get() for obj in objects]
        if "" not in object_list:
            if self.states[state_name]["value"] == []:
                self.states[state_name]["value"] = [object_list]
                self.temporary_window.destroy()
            else:
                self.states[state_name]["value"].append(object_list)
                self.temporary_window.destroy()
        else:
            messagebox.showinfo("Error", "Please select all objects")
            self.temporary_window.destroy()
        self.update_sidebar()
        self.clear_widgets()               
    
    def state_combo_update(self, event, combo):
        combo_type = combo.get()
        if combo_type == "Boolean":
            ttk.Label(self.input_area, text="State Value:").grid(row=2, column=0)
            state_value = ttk.Combobox(self.input_area, values=["True", "False"])
            state_value.grid(row=2, column=1)
            state_value.bind("<FocusOut>", lambda event, e=state_value: self.on_focus_out_entry(event, e))
            ttk.Button(self.input_area, text="Add State", command=lambda: self.add_state(combo_type)).grid(row=3, column=1)
        elif combo_type == "Discrete":
            ttk.Label(self.input_area, text="Possible States (comma-separated):").grid(row=2, column=0)
            states_entry = ttk.Entry(self.input_area)
            states_entry.grid(row=2, column=1)
            states_entry.bind("<FocusOut>", lambda event, e=states_entry: self.on_focus_out_entry(event, e))
            ttk.Button(self.input_area, text="Add State", command=lambda: self.add_state(combo_type)).grid(row=3, column=1)
        elif combo_type == "Range":
            ttk.Label(self.input_area, text="Integer ranging from X to Y (X,Y):").grid(row=2, column=0)
            range_entry = ttk.Entry(self.input_area)
            range_entry.grid(row=2, column=1)
            range_entry.bind("<FocusOut>", lambda event, e=range_entry: self.on_focus_out_entry(event, e))
            ttk.Button(self.input_area, text="Add State", command=lambda: self.add_state(combo_type)).grid(row=3, column=1)
        elif combo_type == "Predicate":
            ttk.Label(self.input_area, text="Object in predicate").grid(row=2, column=0)
            object_combo = ttk.Combobox(self.input_area, values=["agent", "location"]+list(self.objects.keys()))
            object_combo.grid(row=2, column=1)
            ttk.Button(self.input_area, text="Add object to predicate", command=lambda: self.add_required_object_to_list(object_combo.get(), "main")).grid(row=3, column=1)
            ttk.Button(self.input_area, text="Add State", command=lambda: self.add_state(combo_type)).grid(row=4, column=1)
            

    def on_focus_out(self, event, entry, state_effect=None, pos=None, deletion=None):
        if state_effect is not None and pos is not None:
            self.state_change[pos] = f"{state_effect}{entry.get()}"
        elif deletion is not None and pos is not None:
            self.deletion[pos] = f"Delete {entry.get()}"
        else:
            self.name = entry.get()

    def on_focus_out_entry(self, event, entry):
        self.entry = entry.get()
        print(self.entry)

    def on_combobox_select(self, event, combo, allow_create=True):
        combo_name = combo.get()
        if combo_name == "Combine" and allow_create:
            self.add_created_oject()
            self.add_combo_object()
        elif combo_name == "Create" and allow_create:
            self.add_created_oject()
        elif combo_name == "Change State":
            if self.temporary_window is not None:
                try:
                    self.temporary_window.destroy()
                except:
                    print("temporary window does not exist or caused somekind of error")
                self.temporary_window = None
            self.temporary_window = tk.Toplevel(self.root, padx=20, pady=20)
            self.temporary_window.title("Change State")
            ttk.Label(self.temporary_window, text="State to change:").grid(row=0, column=0)
            state_combo = ttk.Combobox(self.temporary_window, values=list(self.states.keys()))
            state_combo.grid(row=0, column=1)
            state_combo.bind("<<ComboboxSelected>>", lambda event: self.state_change_select(event, state_combo, allow_create))
        elif combo_name == "Delete":
            if self.temporary_window is not None:
                try:
                    self.temporary_window.destroy()
                except:
                    print("temporary window does not exist or caused somekind of error")
                self.temporary_window = None
            self.temporary_window = tk.Toplevel(self.root, padx=20, pady=20)
            self.temporary_window.title("Delete Object")
            ttk.Label(self.temporary_window, text="Object to delete:").grid(row=0, column=0)
            object_combo = ttk.Combobox(self.temporary_window, values=list(self.objects.keys()))
            object_combo.grid(row=0, column=1)
            ttk.Button(self.temporary_window, text="Delete Object", command=lambda: self.delete_object(object_combo.get(), allow_create)).grid(row=1, column=1)
        if self.effects["effect1"].get() != "Combine" and self.effects["effect2"].get() != "Combine":
            try:
                for widget in self.input_area_3.winfo_children():
                    widget.destroy()
            except:
                print("error detected while closing input area 3")
            if self.effects["effect1"].get() != "Create" and self.effects["effect2"].get() != "Create":
                try:
                    for widget in self.input_area_2.winfo_children():
                        widget.destroy()
                except:
                    print("error detected while closing input area 2")
        self.reset_available_effects()
        if self.effects["effect1"].get() != "":
            self.available_effects_2.remove(self.effects["effect1"].get())
            self.effects["effect2"]["values"] = self.available_effects_2
        if self.effects["effect2"].get() != "":
            self.available_effects_1.remove(self.effects["effect2"].get())
            self.effects["effect1"]["values"] = self.available_effects_1
        return combo_name

    def state_change_select(self, event, state_combo, main_object):
        state_name = state_combo.get()
        if self.states[state_name]["type"] == "Boolean":
            ttk.Label(self.temporary_window, text="Choose what happens:").grid(row=1, column=0)
            new_state = ttk.Combobox(self.temporary_window, values=["Toggle", "Set"])
            new_state.grid(row=1, column=1)
        elif self.states[state_name]["type"] == "Discrete":
            ttk.Label(self.temporary_window, text="Choose what happens:").grid(row=1, column=0)
            new_state = ttk.Combobox(self.temporary_window, values=["Set", "Rotate"])
            new_state.grid(row=1, column=1)
        elif self.states[state_name]["type"] == "Range":
            ttk.Label(self.temporary_window, text="Choose what happens:").grid(row=1, column=0)
            new_state = ttk.Combobox(self.temporary_window, values=["Increase", "Set", "Decrease"])
            new_state.grid(row=1, column=1)
        elif self.states[state_name]["type"] == "Predicate":
            ttk.Label(self.temporary_window, text="Choose what happens:").grid(row=1, column=0)
            new_state = ttk.Combobox(self.temporary_window, values=["Set", "Unset"])
            new_state.grid(row=1, column=1)
        new_state.bind("<<ComboboxSelected>>", lambda event: self.state_change_select_update(event, self.states[state_name]["type"], new_state.get(), main_object, state_name))

    def state_change_select_update(self, event, state_type, change_option, main_object, state_name):
        if main_object:
            position = "main"
        else:
            position = "secondary"
        if state_type == "Boolean":
            if change_option == "Toggle":
                self.state_change[position] = f"Toggle {state_name}"
            else:
                ttk.Label(self.temporary_window, text="New Value:").grid(row=2, column=0)
                new_value = ttk.Combobox(self.temporary_window, values=["True", "False"])
                new_value.grid(row=2, column=1)
                new_value.bind("<FocusOut>", lambda event, e=new_value: self.on_focus_out(event, e, f"Set {state_name} to ", position))
                self.state_change[position] = f"Set {state_name} to {self.name}"
            ttk.Button(self.temporary_window, text="Save state change", command=self.close_window).grid(row=3, column=1)
        elif state_type == "Discrete":
            if change_option == "Set":
                ttk.Label(self.temporary_window, text="New State:").grid(row=2, column=0)
                new_value = ttk.Combobox(self.temporary_window, values=self.states[state_name]["states"])
                new_value.grid(row=2, column=1)
                new_value.bind("<FocusOut>", lambda event, e=new_value: self.on_focus_out(event, e, f"Set {state_name} to ", position))
            else:
                self.state_change[position] = f"Rotate {state_name}"
            ttk.Button(self.temporary_window, text="Save state change", command=self.close_window).grid(row=3, column=1)
        elif state_type == "Predicate":
            if change_option == "Set":
                ttk.Label(self.temporary_window, text=f"Set {state_name} Predicate").grid(row=2, column=0)
                objects = []
                for idx, parameter in enumerate(list(self.states[state_name]["states"])):
                    element_list = []
                    if parameter == "agent":
                        element_list.append("agent")
                    if parameter == "location":
                        element_list += [name for name, value in self.locations.items()]
                    else:    
                        element_list += [name for name, value in self.objects.items() if name == parameter]
                    ttk.Label(self.temporary_window, text=f"Select {parameter}").grid(row=3+idx, column=0)
                    objects.append(ttk.Combobox(self.temporary_window, values=element_list))
                    objects[idx].grid(row=3+idx, column=0)
                    
                ttk.Button(self.temporary_window, text="Confirm selection", command=lambda: self.save_predicate(objects, state_name, True, position)).grid(row=len(list(self.states[state_name]["states"]))+3, column=1)
                
            else:
                self.state_change[position] = f"Unset {state_name} Predicate"
                objects = []
                for idx, parameter in enumerate(list(self.states[state_name]["states"])):
                    element_list = []
                    if parameter == "agent":
                        element_list.append("agent")
                    if parameter == "location":
                        element_list += [name for name, value in self.locations.items()]
                    else:    
                        element_list += [name for name, value in self.objects.items() if name == parameter]
                    ttk.Label(self.temporary_window, text=f"Select {parameter}").grid(row=3+idx, column=0)
                    objects.append(ttk.Combobox(self.temporary_window, values=element_list))
                    objects[idx].grid(row=3+idx, column=0)
                    
                ttk.Button(self.temporary_window, text="Confirm selection", command=lambda: self.save_predicate(objects, state_name, False, position)).grid(row=len(list(self.states[state_name]["states"]))+3, column=1)
                
            ttk.Button(self.temporary_window, text="Save state change", command=self.close_window).grid(row=len(list(self.states[state_name]["states"]))+4, column=1)
        else:
            if change_option == "Increase":
                ttk.Label(self.temporary_window, text="Increase by:").grid(row=2, column=0)
                new_value = ttk.Entry(self.temporary_window)
                new_value.grid(row=2, column=1)
                new_value.bind("<FocusOut>", lambda event, e=new_value: self.on_focus_out(event, e,f"Increase {state_name} by ", position))
            elif change_option == "Decrease":
                ttk.Label(self.temporary_window, text="Decrease by:").grid(row=2, column=0)
                new_value = ttk.Entry(self.temporary_window)
                new_value.grid(row=2, column=1)
                new_value.bind("<FocusOut>", lambda event, e=new_value: self.on_focus_out(event, e, f"Decrease {state_name} by ", position))
            else:
                ttk.Label(self.temporary_window, text="New Value:").grid(row=2, column=0)
                new_value = ttk.Entry(self.temporary_window)
                new_value.grid(row=2, column=1)
                new_value.bind("<FocusOut>", lambda event, e=new_value: self.on_focus_out(event, e, f"Set {state_name} to ", position))
            ttk.Button(self.temporary_window, text="Save state change", command=self.close_window).grid(row=3, column=1)
    
    def save_predicate(self, objects, predicate_name, set_predicate, position):
        if set_predicate:
            self.state_change[position] = f"Set {predicate_name} Predicate to"
        else:
            self.state_change[position] = f"Unset {predicate_name} Predicate to"
        for obj in objects:
            self.state_change[position] += f" {obj.get()}"       

    def close_window(self, combo=None):
        if combo is not None:
            self.states[self.name]["value"] = combo.get()
        self.temporary_window.destroy()
        
    def delete_object(self, object_name, allow_create):
        if allow_create:
            pos = "main"
        else:
            pos = "secondary"
        self.deletion[pos] = f"Delete {object_name}"
        self.temporary_window.destroy()


    def add_required_object(self, pos=None):
        #function with dropbox to select object a button to add it to the list and another button to be done and close the window
        if pos == "secondary":
            position = "secondary"
        else:
            position = "main"
        if self.temporary_window is not None:
            try:
                self.temporary_window.destroy()
            except:
                print("temporary window does not exist or caused somekind of error")
            self.temporary_window = None
        self.temporary_window = tk.Toplevel(self.root, padx=20, pady=20)
        self.temporary_window.title("Select Required Objects")
        ttk.Label(self.temporary_window, text="Select Object:").grid(row=0, column=0)
        object_combo = ttk.Combobox(self.temporary_window, values=[obj for obj in list(self.objects.keys()) if obj not in list(self.requires_objects[pos])])
        object_combo.grid(row=0, column=1)
        ttk.Button(self.temporary_window, text="Add Object", command=lambda: self.add_required_object_to_list(object_combo.get(), position)).grid(row=1, column=1)
        ttk.Button(self.temporary_window, text="Done", command=self.close_window).grid(row=2, column=1)
    
    def add_required_object_to_list(self, object_name, position):
        if position == "secondary":
            if object_name not in self.requires_objects["secondary"]:
                self.requires_objects["secondary"].append(object_name)
        else:
            if object_name not in self.requires_objects["main"]:
                self.requires_objects["main"].append(object_name)
        print(f"The object {object_name} is required")
    
    def add_required_state(self, pos):
        if pos == "secondary":
            position = "secondary"
        else:
            position = "main"
        if self.temporary_window is not None:
            try:
                self.temporary_window.destroy()
            except:
                print("temporary window does not exist or caused somekind of error")
            self.temporary_window = None
        self.temporary_window = tk.Toplevel(self.root, padx=20, pady=20)
        self.temporary_window.title("Select Required States")
        ttk.Label(self.temporary_window, text="Select State:").grid(row=0, column=0)
        state_combo = ttk.Combobox(self.temporary_window, values=[state for state in list(self.states.keys()) if state not in list(self.requires_states[pos].keys())])
        state_combo.grid(row=0, column=1)
        
        state_combo.bind("<<ComboboxSelected>>", lambda event: self.required_state_value_select(event, state_combo.get(), position))
        
    def required_state_value_select(self, event, state_name, position):
        ttk.Label(self.temporary_window, text="State Value(s):").grid(row=1, column=0)
        if self.states[state_name]["type"] == "Boolean":
            state_value = ttk.Combobox(self.temporary_window, values=["True", "False"])
        elif self.states[state_name]["type"] == "Discrete":
            state_value = ttk.Combobox(self.temporary_window, values=self.states[state_name]["states"])
        elif self.states[state_name]["type"] == "Predicate":
            objects = []
            for idx, parameter in enumerate(list(self.states[state_name]["states"])):
                element_list = []
                if parameter == "agent":
                    element_list.append("agent")
                if parameter == "location":
                    element_list += [name for name, value in self.locations.items()]
                else:    
                    element_list += [name for name, value in self.objects.items() if name == parameter]
                ttk.Label(self.temporary_window, text=f"Select {parameter}").grid(row=2+idx, column=0)
                objects.append(ttk.Combobox(self.temporary_window, values=element_list))
                objects[idx].grid(row=2+idx, column=1)
        else:
            state_value = ttk.Entry(self.temporary_window)
            
        if self.states[state_name]["type"] == "Predicate":
            ttk.Button(self.temporary_window, text="Add State", command=lambda: self.add_required_predicates_to_list(state_name, objects, position)).grid(row=len(list(self.states[state_name]["states"]))+3, column=0)
            ttk.Button(self.temporary_window, text="Done", command=self.close_window).grid(row=len(list(self.states[state_name]["states"]))+3, column=1)
        else:
            state_value.grid(row=1, column=1)
            state_value.bind("<FocusOut>", lambda event: self.required_state_value_capture(event, state_value.get())) 
            ttk.Button(self.temporary_window, text="Add State", command=lambda: self.add_required_state_to_list(state_name, position)).grid(row=2, column=0)
            ttk.Button(self.temporary_window, text="Done", command=self.close_window).grid(row=2, column=1)
    
    def required_state_value_capture(self, event, state_value):
        self.temp_required_state_value = state_value    
    
    def add_required_state_to_list(self, state_name, position):
        if position == "secondary":
            if state_name not in self.requires_states["secondary"]:
                self.requires_states["secondary"][state_name] = self.temp_required_state_value
        else:
            if state_name not in self.requires_states["main"]:
                self.requires_states["main"][state_name] = self.temp_required_state_value
        print(f"The state {state_name} must be equal to {self.temp_required_state_value}")
    
    def add_required_predicates_to_list(self, state_name, objects, position):
        object_list = [obj.get() for obj in objects]
        if position == "secondary":
            if state_name not in self.requires_states["secondary"]:
                self.requires_states["secondary"][state_name] = [object_list]
            else:
                if object_list not in self.requires_states["secondary"][state_name]:
                    self.requires_states["secondary"][state_name].append(object_list)            
        else:
            if state_name not in self.requires_states["main"]:
                self.requires_states["main"][state_name] = [object_list]
            else:
                if object_list not in self.requires_states["main"][state_name]:
                    self.requires_states["main"][state_name].append(object_list)  
        print(f"The state {state_name} must be equal to {object_list}")        
            
    def add_required_location(self, pos=None):
        if pos == "secondary":
            position = "secondary"
        else:
            position = "main"
        if self.temporary_window is not None:
            try:
                self.temporary_window.destroy()
            except:
                print("temporary window does not exist or caused somekind of error")
            self.temporary_window = None
        self.temporary_window = tk.Toplevel(self.root, padx=20, pady=20)
        self.temporary_window.title("Select Required Location")
        ttk.Label(self.temporary_window, text="Select Location:").grid(row=0, column=0)
        location_combo = ttk.Combobox(self.temporary_window, values=list(self.locations.keys()))
        location_combo.grid(row=0, column=1)
        ttk.Button(self.temporary_window, text="Set Location", command=lambda: self.add_required_location_to_list(location_combo.get(), position)).grid(row=1, column=1)
        ttk.Button(self.temporary_window, text="Done", command=self.close_window).grid(row=2, column=1)
        
    def add_required_location_to_list(self, location_name, position):
        if position == "secondary":
            self.required_location["secondary"] = location_name
        else:
            self.required_location["main"] = location_name
        print(f"Required Location set to : {location_name}")
        
    def add_existing_object(self):
        pass

    def add_created_oject(self):
        pos = "secondary"
        ttk.LabelFrame(self.input_area_2, text="Created Object").grid(row=0, columnspan=2)

        ttk.Label(self.input_area_2, text="Created Name:").grid(row=1, column=0)
        self.entries["name_create"] = ttk.Entry(self.input_area_2)
        self.entries["name_create"].grid(row=1, column=1)

        ttk.Label(self.input_area_2, text="Location:").grid(row=2, column=0)
        self.location_combos["location_create"] = ttk.Combobox(self.input_area_2, values=list(self.locations.keys()))
        self.location_combos["location_create"].grid(row=2, column=1)

        self.movable["movable_create"] = tk.BooleanVar()
        ttk.Checkbutton(self.input_area_2, text="Movable", variable=self.movable["movable_create"]).grid(row=3, column=1)

        self.consumed["consumed_create"] = tk.BooleanVar()
        ttk.Checkbutton(self.input_area_2, text="Consumed upon use", variable=self.consumed["consumed_create"]).grid(row=4, column=1)
        
        ttk.Label(self.input_area_2, text="Requires Objects:").grid(row=5, column=0)
        ttk.Button(self.input_area_2, text="Select Required Objects", command=lambda: self.add_required_object(pos)).grid(row=5, column=1)
        
        ttk.Label(self.input_area_2, text="Requires States:").grid(row=6, column=0)
        ttk.Button(self.input_area_2, text="Select Required States", command=lambda: self.add_required_state(pos)).grid(row=6, column=1)
        
        ttk.Label(self.input_area_2, text="Required Location:").grid(row=7, column=0)
        ttk.Button(self.input_area_2, text="Select Required Location", command=lambda: self.add_required_location(pos)).grid(row=7, column=1)

        ttk.Label(self.input_area_2, text="Effect 1:").grid(row=8, column=0)
        self.effects["effect1_create"] = ttk.Combobox(self.input_area_2,
                                                        values=["None", "Change State", "Create", "Combine", "Delete"])
        self.effects["effect1_create"].grid(row=8, column=1)

        ttk.Label(self.input_area_2, text="Effect 2:").grid(row=9, column=0)
        self.effects["effect2_create"] = ttk.Combobox(self.input_area_2,
                                                        values=["None", "Change State", "Create", "Combine", "Delete"])
        self.effects["effect2_create"].grid(row=9, column=1)

        self.effects["effect1_create"].bind("<<ComboboxSelected>>", lambda event, e=self.effects[
            "effect1_create"]: self.on_combobox_select(event, e, False))
        self.effects["effect2_create"].bind("<<ComboboxSelected>>", lambda event, e=self.effects[
            "effect2_create"]: self.on_combobox_select(event, e, False))

    def add_combo_object(self):
        ttk.LabelFrame(self.input_area_3, text="Combination Object").grid(row=0, columnspan=2)

        ttk.Label(self.input_area_3, text="Combination Object Name:").grid(row=1, column=0)
        self.entries["name_combo"] = ttk.Combobox(self.input_area_3, values=list(self.objects.keys())).grid(row=1, column=1)


    def add_object(self):
        pos = "main"
        ttk.Label(self.input_area, text="Name:").grid(row=0, column=0)
        self.entries["name"] = ttk.Entry(self.input_area)
        self.entries["name"].grid(row=0, column=1)

        ttk.Label(self.input_area, text="Location:").grid(row=1, column=0)
        self.location_combos["location"] = ttk.Combobox(self.input_area, values=list(self.locations.keys()))
        self.location_combos["location"].grid(row=1, column=1)

        self.movable["movable"] = tk.BooleanVar()
        ttk.Checkbutton(self.input_area, text="Movable", variable=self.movable["movable"]).grid(row=2, column=1)

        self.consumed["consumed"] = tk.BooleanVar()
        ttk.Checkbutton(self.input_area, text="Consumed upon use", variable=self.consumed["consumed"]).grid(row=3, column=1)
        
        ttk.Label(self.input_area, text="Requires Objects:").grid(row=4, column=0)
        ttk.Button(self.input_area, text="Select Required Objects", command=lambda: self.add_required_object(pos)).grid(row=4, column=1)
        
        ttk.Label(self.input_area, text="Requires States:").grid(row=5, column=0)
        ttk.Button(self.input_area, text="Select Required States", command=lambda: self.add_required_state(pos)).grid(row=5, column=1)
        
        ttk.Label(self.input_area, text="Required Location:").grid(row=6, column=0)
        ttk.Button(self.input_area, text="Select Required Location", command=lambda: self.add_required_location(pos)).grid(row=6, column=1)

        ttk.Label(self.input_area, text="Effect 1:").grid(row=7, column=0)
        self.effects["effect1"] = ttk.Combobox(self.input_area,
                                                        values=self.available_effects_1)
        self.effects["effect1"].grid(row=7, column=1)

        ttk.Label(self.input_area, text="Effect 2:").grid(row=8, column=0)
        self.effects["effect2"] = ttk.Combobox(self.input_area,
                                                        values=self.available_effects_2)
        self.effects["effect2"].grid(row=8, column=1)

        effect_name = self.effects["effect1"].bind("<<ComboboxSelected>>", lambda event: self.on_combobox_select(event, self.effects[
            "effect1"]))
        effect_name = self.effects["effect2"].bind("<<ComboboxSelected>>", lambda event: self.on_combobox_select(event, self.effects[
            "effect2"]))

        ttk.Button(self.input_area, text="Add Object", command=lambda: self.process_new_object()).grid(
            row=9, columnspan=2
        )

        # Add new form fields similar to the original 'add_object' method

    def add_location(self, name, x, y, is_start):
        if name and x is not None and y is not None:
            self.locations[name] = {"coords": (x, y), "agent_start": is_start}
            self.update_sidebar()

    def  add_state(self, state_type):
        if self.name:
            self.states[self.name] = {"name": self.name, "type": state_type}
            if state_type == "Discrete":
                self.states[self.name]["states"] = self.entry.split(",")
                if self.temporary_window is not None:
                    try:
                        self.temporary_window.destroy()
                    except:
                        print("temporary window does not exist or caused somekind of error")
                    self.temporary_window = None
                self.temporary_window = tk.Toplevel(self.root, padx=10, pady=10)
                self.temporary_window.title("Select Current State:")
                ttk.Label(self.temporary_window, text="Current State:").grid(row=0, column=0)
                state_combo = ttk.Combobox(self.temporary_window, values=self.states[self.name]["states"])
                state_combo.grid(row=0, column=1)
                ttk.Button(self.temporary_window, text="Save State", command=lambda: self.close_window(state_combo)).grid(row=1, column=1)
                self.root.wait_window(self.temporary_window)
            elif state_type == "Range":
                range_values = [*map(int, self.entry.split(","))]
                range_values[-1] += 1 
                self.states[self.name]["states"] = [*map(str, range(*range_values))]
                if self.temporary_window is not None:
                    try:
                        self.temporary_window.destroy()
                    except:
                        print("temporary window does not exist or caused somekind of error")
                    self.temporary_window = None
                self.temporary_window = tk.Toplevel(self.root, padx=10, pady=10)
                self.temporary_window.title("Select Current State:")
                ttk.Label(self.temporary_window, text="Current State:").grid(row=0, column=0)
                state_combo = ttk.Combobox(self.temporary_window, values=self.states[self.name]["states"])
                state_combo.grid(row=0, column=1)
                ttk.Button(self.temporary_window, text="Save State", command=lambda: self.close_window(state_combo)).grid(row=1, column=1)
                self.root.wait_window(self.temporary_window)
            elif state_type == "Boolean":
                self.states[self.name]["value"] = self.entry
            elif state_type == "Predicate":
                self.states[self.name]["states"] = self.requires_objects["main"]
                self.states[self.name]["value"] = []
                self.requires_objects["main"] = []
            self.update_sidebar()
            self.clear_widgets()
    
    def process_new_object(self):
        if self.entries["name"].get() and self.location_combos["location"].get():
            effects = []
            for effect in [self.effects["effect1"].get(), self.effects["effect2"].get()]:
                if effect == "Create":
                    if self.effects["effect1_create"].get() == "Change State":
                        self.effects["effect1_create"] = self.state_change["secondary"]
                    elif self.effects["effect2_create"].get() == "Change State":
                        self.effects["effect2_create"] = self.state_change["secondary"]
                    elif self.effects["effect1_create"].get() == "Delete":
                        self.effects["effect1_create"] = self.deletion["secondary"]
                    elif self.effects["effect2_create"].get() == "Delete":
                        self.effects["effect2_create"] = self.deletion["secondary"]
                    if self.requires_objects["secondary"] == []:
                        self.requires_objects["secondary"] = None
                    if not self.requires_states["secondary"]:
                        self.requires_states["secondary"] = None
                    effects.append(f"Create {self.entries['name_create'].get()} at location {self.location_combos['location_create'].get()} is movable = {self.movable['movable_create'].get()} is consumed = {self.consumed['consumed_create'].get()} effects = {self.effects['effect1_create']}, {self.effects['effect2_create']} requires_objects = {self.requires_objects['secondary']} requires_states = {self.requires_states['secondary']} requires_location = {self.required_location['secondary']}")
                elif effect == "Combine":
                    if self.effects["effect1_create"].get() == "Change State":
                        self.effects["effect1_create"] = self.state_change["secondary"]
                    elif self.effects["effect2_create"].get() == "delete":
                        self.effects["effect2_create"] = self.deletion["secondary"]
                    else:
                        self.effects["effect1_create"] = self.effects["effect1_create"].get()
                    if self.effects["effect2_create"].get() == "Change State":
                        self.effects["effect2_create"] = self.state_change["secondary"]
                    elif self.effects["effect2_create"].get() == "delete":
                        self.effects["effect2_create"] = self.deletion["secondary"]
                    else:
                        self.effects["effect2_create"] = self.effects["effect2_create"].get()
                    effects.append(f"Combine {self.entries['name'].get()} with {self.entries['name_combo'].get()} create {self.entries['name_create'].get()} is movable = {self.movable['movable_create'].get()} is consumed = {self.consumed['consumed_create'].get()} effects = {self.effects['effect1_create']}, {self.effects['effect2_create']} requires_objects = {self.requires_objects['secondary']} requires_states = {self.requires_states['secondary']} requires_location = {self.required_location['secondary']}")
                    if self.entries["name_combo"].get() not in list(self.objects.values()):
                        print("Warning - Combination object not found in objects list")
                elif effect == "Change State":
                    effects.append(self.state_change["main"])
                elif effect == "Delete":
                    effects.append(self.deletion["main"])                
                else:
                    effects.append(effect)
                if self.requires_objects["main"] == []:
                    self.requires_objects["main"] = None
                if not self.requires_states["main"]:
                    self.requires_states["main"] = None
            self.objects[self.entries["name"].get()] = {
                "location": self.location_combos["location"].get(),
                "movable": self.movable["movable"].get(),
                "consumed": self.consumed["consumed"].get(),
                "effects": effects,
                "requires_objects": self.requires_objects["main"],
                "requires_states": self.requires_states["main"],
                "required_location": self.required_location["main"]
            }
            try:
                self.temporary_window.destroy()
            except:
                print("temporary window does not exist or caused somekind of error")
            self.update_sidebar()
            self.reset_available_effects()
            self.entries = {}
            self.effects = {}
            self.location_combos = {}
            self.movable = {}
            self.consumed = {}
            self.state_change = {"main": "None", "secondary": "None"}
            self.requires_objects = {"main": [], "secondary": []}
            self.requires_states = {"main": {}, "secondary": {}}
            
    def process_extra_object(self):
        name = self.name
        obj_type = self.combo_selection.get()
        location = self.location_combos["element"].get()
        
        self.elements[name] = {"location": location, "type": obj_type}
        
        self.update_sidebar()
        self.location_combos = {}
        self.name = None
        self.combo_selection = None


    def load_configuration(self):
        try:
            config = json.load(open(self.setup_name + ".json"))
            self.locations = config["locations"]
            self.states = config["states"]
            self.objects = config["objects"]
            self.elements = config["elements"]
            self.update_sidebar()
            messagebox.showinfo("Load", "Configuration loaded successfully!")
        except:
            print(f"Unable to load {self.setup_name + '.json'} file. Please check the file and try again.")

    def save_configuration(self, start=False):
        config = {
            "locations": self.locations,
            "states": self.states,
            "objects": self.objects,
            "elements": self.elements,
            "start": start
        }
        with open(self.setup_name + ".json", 'w') as f:
            json.dump(config, f, indent=4)
        if start:
            messagebox.showinfo("Save", "Configuration saved successfully!")
        else:
            print("Configuration saved successfully!")

    def update_sidebar(self):
        self.listbox.delete(0, tk.END)
        self.listbox.insert(tk.END, "Locations:")
        for loc, details in self.locations.items():
            self.listbox.insert(tk.END, f"{loc}: {details}")
        self.listbox.insert(tk.END, "States:")
        for state, details in self.states.items():
            self.listbox.insert(tk.END, f"{state}: {details}")
        self.listbox.insert(tk.END, "Object Types:")
        for obj, details in self.objects.items():
            self.listbox.insert(tk.END, f"{obj}: {details}")
        self.listbox.insert(tk.END, "Objects:")
        for element, details in self.elements.items():
            self.listbox.insert(tk.END, f"{element}: {details}")
        self.clear_widgets()
        self.save_configuration()


if __name__ == "__main__":
    setup_name = "open_world"
    root = tk.Tk()
    app = GameStateEditor(root, setup_name)
    root.mainloop()
