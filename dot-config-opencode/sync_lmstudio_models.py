import json
import urllib.request
import os

LM_STUDIO_URL = os.getenv("LM_STUDIO_URL", "http://127.0.0.1:1234/v1/models")
CONFIG_FILE = "opencode.json"

DEFAULT_CONTEXT = 32768
DEFAULT_OUTPUT = 4096

def fetch_models():
    try:
        with urllib.request.urlopen(LM_STUDIO_URL) as response:
            if response.status == 200:
                data = json.loads(response.read().decode())
                return [model['id'] for model in data.get('data', [])]
            else:
                print(f"Error: Received status code {response.status}")
                return None
    except Exception as e:
        print(f"Error fetching models from LM Studio: {e}")
        return None

def format_name(model_id):
    # A simple way to make the name look better
    # Replace dashes and dots with spaces, then title case
    name = model_id.replace('-', ' ').replace('.', ' ')
    return name.title()

def update_config(model_ids):
    if not os.path.exists(CONFIG_FILE):
        print(f"Error: {CONFIG_FILE} not found.")
        return

    try:
        with open(CONFIG_FILE, 'r') as f:
            config = json.load(f)

        if 'provider' not in config or 'lmstudio' not in config['provider']:
             print("Error: 'lmstudio' provider not found in config.")
             return
        
        lmstudio_provider = config['provider']['lmstudio']
        
        # Update baseURL if LM_STUDIO_URL is provided and different
        if 'options' not in lmstudio_provider:
            lmstudio_provider['options'] = {}
        
        current_base_url = lmstudio_provider['options'].get('baseURL', "")
        expected_base_url = LM_STUDIO_URL.rsplit('/models', 1)[0] if LM_STUDIO_URL.endswith('/models') else LM_STUDIO_URL
        
        if current_base_url != expected_base_url:
            lmstudio_provider['options']['baseURL'] = expected_base_url

        if 'models' not in lmstudio_provider:
            lmstudio_provider['models'] = {}

        models_section = lmstudio_provider['models']
        new_models_section = {}

        for model_id in model_ids:
            # Preserve existing configuration if it exists
            if model_id in models_section:
                existing_model = models_section[model_id]
                name = existing_model.get('name', format_name(model_id))
                limit = existing_model.get('limit', {"context": DEFAULT_CONTEXT, "output": DEFAULT_OUTPUT})
            else:
                name = format_name(model_id)
                limit = {"context": DEFAULT_CONTEXT, "output": DEFAULT_OUTPUT}

            new_models_section[model_id] = {
                "name": name,
                "limit": limit
            }

        lmstudio_provider['models'] = new_models_section

        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"Successfully updated {CONFIG_FILE} with {len(model_ids)} models.")

    except Exception as e:
        print(f"Error updating config: {e}")

if __name__ == "__main__":
    print("Fetching models from LM Studio...")
    models = fetch_models()
    if models is not None:
        print(f"Found {len(models)} models.")
        update_config(models)
    else:
        print("Failed to sync models. Is LM Studio running?")
