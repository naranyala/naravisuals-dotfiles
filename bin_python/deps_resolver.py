
import ast
import sys
import importlib.util

def get_imports_from_file(filepath):
    with open(filepath, "r", encoding="utf-8") as f:
        tree = ast.parse(f.read(), filename=filepath)

    imports = set()
    for node in ast.walk(tree):
        if isinstance(node, ast.Import):
            for alias in node.names:
                imports.add(alias.name.split(".")[0])
        elif isinstance(node, ast.ImportFrom):
            if node.module:
                imports.add(node.module.split(".")[0])
    return imports

def is_stdlib(module_name):
    """Check if a module is part of the standard library."""
    if module_name in sys.builtin_module_names:
        return True
    spec = importlib.util.find_spec(module_name)
    if spec is None:
        return False
    return "site-packages" not in (spec.origin or "")

def resolve_dependencies(filepath):
    imports = get_imports_from_file(filepath)
    third_party = [m for m in imports if not is_stdlib(m)]
    return third_party

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python resolver.py <target_file.py>")
        sys.exit(1)

    target_file = sys.argv[1]
    deps = resolve_dependencies(target_file)

    print("Dependencies found:")
    for dep in deps:
        print(f"- {dep}")

    print("\nSuggested uv command:")
    print("uv pip install " + " ".join(deps))
