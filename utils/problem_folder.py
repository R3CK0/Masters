import os
import shutil


def move_pfile_to_problems(root_folder):
    # Walk through the directory
    for subdir, dirs, files in os.walk(root_folder):
        for file in files:
            if file.startswith("pfile"):
                # Create "problems" folder in the current subfolder if it doesn't exist
                problems_folder = os.path.join(subdir, "problems")
                if not os.path.exists(problems_folder):
                    os.makedirs(problems_folder)

                # Move the pfile to the "problems" folder
                source_file = os.path.join(subdir, file)
                destination_file = os.path.join(problems_folder, file)
                shutil.move(source_file, destination_file)
                print(f"Moved {source_file} to {destination_file}")

def add_subdomains_folder(root_folder):
    # Walk through the directory
    for subdir, dirs, files in os.walk(root_folder):
        # Check if any file in the current subfolder has a .pddl extension
        if any(file.endswith(".pddl") for file in files):
            # Create "subdomains" folder in the current subfolder if it doesn't exist
            subdomains_folder = os.path.join(subdir, "subdomains")
            if not os.path.exists(subdomains_folder):
                os.makedirs(subdomains_folder)
                print(f"Created {subdomains_folder}")


def remove_untyped_extension(root_folder):
    # Walk through the directory
    for subdir, dirs, files in os.walk(root_folder):
        for file in files:
            if file.endswith(".untyped"):
                # Construct the full file path
                old_file_path = os.path.join(subdir, file)

                # Create new file name by removing the .untyped extension
                new_file_path = os.path.join(subdir, file[:-8])  # Remove the last 8 characters (.untyped)

                # Rename the file
                os.rename(old_file_path, new_file_path)
                print(f"Renamed {old_file_path} to {new_file_path}")


def copy_pddl_to_subdomain(root_folder):
    # Walk through the directory
    for subdir, dirs, files in os.walk(root_folder):
        for file in files:
            if file.endswith(".pddl"):
                # Construct the full file path
                source_file_path = os.path.join(subdir, file)

                # Create "subdomains" folder in the current subfolder if it doesn't exist
                subdomains_folder = os.path.join(subdir, "subdomains")
                if not os.path.exists(subdomains_folder):
                    os.makedirs(subdomains_folder)
                    print(f"Created {subdomains_folder}")

                # Construct the destination file path
                destination_file_path = os.path.join(subdomains_folder, file)

                # Copy the .pddl file to the subdomains folder
                shutil.copy2(source_file_path, destination_file_path)
                print(f"Copied {source_file_path} to {destination_file_path}")


def create_pddl_copies_in_subdomains(root_folder):
    # Walk through the directory
    for subdir, dirs, files in os.walk(root_folder):
        # Check if the current folder is named "subdomains"
        if os.path.basename(subdir) == "subdomains":
            for file in files:
                if file.endswith(".pddl"):
                    # Construct the full path to the original file
                    original_file_path = os.path.join(subdir, file)

                    # Create 5 copies of the file with the new naming convention
                    for i in range(1, 6):
                        copy_file_name = f"{file[:-5]}_sub{i}.pddl"  # Remove the last 5 characters (.pddl) and add _sub{i}.pddl
                        copy_file_path = os.path.join(subdir, copy_file_name)

                        # Copy the file
                        shutil.copy2(original_file_path, copy_file_path)
                        print(f"Copied {original_file_path} to {copy_file_path}")


# Usage example
root_folder = "C:/Users/Nicho/OneDrive/Documents/Masters/data/IPC3"
#move_pfile_to_problems(root_folder)
#add_subdomains_folder(root_folder)
#remove_untyped_extension(root_folder)
#copy_pddl_to_subdomain(root_folder)
create_pddl_copies_in_subdomains(root_folder)