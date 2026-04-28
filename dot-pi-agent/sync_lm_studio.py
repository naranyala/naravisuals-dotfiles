import json
import urllib.request
import sys
import os

# Configuration
LM_STUDIO_URL = "http://127.0.0.1:1234/v1/models"
MODELS_JSON_PATH = "agent/models.json"
DEFAULT_CONTEXT_WINDOW = 32768

def fetch_models():
    """Fetches the list of models from LM Studio."""
    print(f"[*] Fetching models from {LM_STUDIO_URL}...")
    try:
        with urllib.request.urlopen(LM_STUDIO_URL) as response:
            data = json.loads(response.read().decode())
            if 'data' not in data:
                print("[!] Error: Unexpected API response format. 'data' field not found.")
                return None
            return data['data']
    except Exception as e:
        print(f"[!] Error connecting to LM Studio: {e}")
        return None

def update_models_json(server_models):
    """Updates the agent/models.json file with the enriched model configuration."""
    if not os.path.exists(MODELS_JSON_PATH):
        print(f"[!] Error: {MODELS_JSON_PATH} does not exist.")
        return

    print(f"[*] Loading existing configuration from {MODELS_JSON_PATH}...")
    try:
        with open(MODELS_JSON_PATH, 'r') as f:
            config = json.load(f)
        
        if "providers" not in config or "lm-studio" not in config["providers"]:
            print("[!] Error: 'lm-studio' provider not found in models.json. Please ensure it's configured.")
            return

        # Build the new models list with enriched metadata
        new_models_list = []
        for model_data in server_models:
            model_id = model_data['id']
            
            # Clean up the name for display
            display_name = model_id.replace("-instruct", "").replace("-it", "").capitalize()
            # If it contains slashes (like provider/model), clean it up too
            if "/" in display_name:
                display_name = display_name.split("/")[-1].capitalize()
            
            new_models_list.append({
                "id": model_id,
                "name": f"{display_name} (Local)",
                "api": "openai",
                "contextWindow": DEFAULT_CONTEXT_WINDOW,
                "reasoning": False,
                "input": ["text"]
            })
        
        # Update the lm-studio provider
        print(f"[*] Replacing existing models with {len(new_models_list)} new models...")
        config["providers"]["lm-studio"]["models"] = new_models_list

        # Save the updated configuration
        with open(MODELS_JSON_PATH, 'w') as f:
            json.dump(config, f, indent=2)
        
        print("[+] Successfully updated models.json with enriched metadata!")
        
    except json.JSONDecodeError:
        print(f"[!] Error: Failed to parse {MODELS_JSON_PATH}. It might be invalid JSON.")
    except Exception as e:
        print(f"[!] An unexpected error occurred: {e}")

if __name__ == "__main__":
    # Ensure we are running from the project root where agent/ is visible
    server_models = fetch_models()
    if server_models:
        update_models_json(server_models)
    else:
        print("[!] Sync failed.")
        sys.exit(1)
