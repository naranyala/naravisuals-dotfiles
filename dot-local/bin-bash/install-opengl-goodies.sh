#!/usr/bin/env bash
set -euo pipefail


### 🧠 What This Covers

# | Library     | Purpose                              |
# |-------------|---------------------------------------|
# | `mesa-utils`| Tools like `glxinfo`, `glxgears`      |
# | `GL`, `GLU` | Core OpenGL and utility functions     |
# | `GLUT`      | Legacy windowing/input toolkit        |
# | `GLEW`      | Extension wrangler for OpenGL         |
# | `GLFW`      | Modern window/context/input toolkit   |
# | `GLM`       | Header-only math library (like GLSL)  |
# | `SDL2`      | Cross-platform media/input/audio      |

echo "🚀 Installing OpenGL development stack..."

sudo apt update

# Core OpenGL and GLU
sudo apt install -y \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  mesa-utils

# GLUT and GLEW
sudo apt install -y \
  freeglut3-dev \
  libglew-dev

# GLFW and GLM (modern OpenGL)
sudo apt install -y \
  libglfw3-dev \
  libglm-dev

# Optional: Audio and media support
sudo apt install -y \
  libao-dev \
  libmpg123-dev

# Optional: SDL2 stack
sudo apt install -y \
  libsdl2-dev \
  libsdl2-image-dev \
  libsdl2-mixer-dev \
  libsdl2-ttf-dev

echo "✅ OpenGL goodies installed!"



