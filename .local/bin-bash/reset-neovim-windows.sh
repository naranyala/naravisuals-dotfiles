
#!/usr/bin/env bash
# Hard reset Neovim cache/config/data

CONFIG=$(nvim --headless +"echo stdpath('config')" +q)
DATA=$(nvim --headless +"echo stdpath('data')" +q)
CACHE=$(nvim --headless +"echo stdpath('cache')" +q)

echo "Removing Neovim directories:"
echo "  Config: $CONFIG"
echo "  Data:   $DATA"
echo "  Cache:  $CACHE"

rm -rf "$CONFIG" "$DATA" "$CACHE"

echo "Neovim reset complete."
