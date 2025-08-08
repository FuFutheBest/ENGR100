![Build badge](https://focs.ji.sjtu.edu.cn/git/SilverFOCS-25su/p1team09/actions/workflows/push.yaml/badge.svg?branch=master)
![Build badge](https://focs.ji.sjtu.edu.cn/git/SilverFOCS-25su/p1team09/actions/workflows/release.yaml/badge.svg?tag=p1m1)
![Build badge](https://focs.ji.sjtu.edu.cn/git/SilverFOCS-25su/p1team09/actions/workflows/release.yaml/badge.svg?tag=p1m2)
![Build badge](https://focs.ji.sjtu.edu.cn/git/SilverFOCS-25su/p1team09/actions/workflows/release.yaml/badge.svg?tag=p1m3)

# Breakout Game - Elm + Messenger Engine

A modern version of the classic Breakout game, implemented using the Elm programming language and powered by the Messenger engine. This project demonstrates how functional programming can create elegant and interactive gameplay.

## Overview

This game combines real-time physics, strategic paddle control, level progression, and clean modular design. It is not only fun to play but also a solid example of applying Elm's architecture to game development.

## Core Features

### Ball Physics

- Realistic angle calculation based on paddle contact
- Dynamic speed control for a smooth experience
- Accurate vector-based collision handling
- Natural acceleration and bouncing behavior

### Paddle System

- Two paddle modes:
  - Normal mode (default)
  - Return mode (up arrow to activate, down arrow to deactivate)
- Smooth horizontal movement with acceleration
- Screen boundary handling

### Brick Mechanics

- Predefined layouts for each level
- Increasing difficulty with level progression
- Impact effects and optional chain reactions
- Score increases as bricks are destroyed

### Game Control

- Pause/Resume with Space key
- Game state management and restart logic
- Lose condition when ball falls below paddle
- Win condition when all bricks are cleared

## Architecture

- **Elm Architecture (MVU)**: Clean separation between model, update, and view
- **Messenger Engine**: Efficient scene and event management
- **Vector Math**: Enables precise ball movement and reflection
- **Modular Design**: Each component lives in its own module for clarity and reuse

## How to Play

- **Left/Right arrows**: Move paddle
- **Up arrow**: Switch to Return mode
- **Down arrow**: Switch back to Normal mode
- **Space**: Pause or resume

### Goal

Break all bricks, keep the ball alive, and advance through levels.

## Development Setup

1. Install Elm:
   ```bash
   npm install -g elm
   ```
2. Clone the repo:
   ```bash
   git clone https://focs.ji.sjtu.edu.cn/git/SilverFOCS-25su/p1team09.git
   ```
3. Start the development server:
   ```bash
   elm reactor
   ```
4. Open in browser:
   ```bash
   http://localhost:8000
   ```

## Authors

Developed by p1team09 for SilverFOCS 2025 Spring.
