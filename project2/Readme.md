# Ghostbust Hotline

![](./assets/lolipop/ghostbust_hotline.png)

A 2D top-down shooter where you play as an exorcist to exterminate ghosts from a dungeon. But here's the catch: the ghosts are invisible, you can neither see nor hit them... _Unless you reveal them first._

---

# Game Philosophy

We prioritized a **refined and polished experience**, especially for a small three-man team.

- Flashy particle effects
- Original Sound Track
- Intuitive but deep mechanics

---

## Developer Notes

- The particle system slightly sacrifices performance for style, a **worthy trade-off**.
- Each ghost requires **unique strategies** based on its behavior and appearance.

# Test it out!

Game available at [SilverFOCS Official Website](https://focs.ji.sjtu.edu.cn/silverfocs/project/2025/p2). We're **p2team02**, by the way.

---

# Installation and Usage

## Installation

**Our development is based on following environments.**

```tex
Windows 10+
Ubuntu 24.04
```

To set up the game, first install `elm` and `Messenger` by running the commands below.

```bash
# Install elm
npm install -g elm

# Install Messenger
# pipx:
pipx install -i https://pypi.python.org/simple elm-messenger>=0.5.3
# uv:
uv tool install -i https://pypi.python.org/simple elm-messenger>=0.5.3
# Or use pip on Windows:
pip install -i https://pypi.python.org/simple elm-messenger>=0.5.3
```

Then pull down the whole repository.

---

## Usage

Firstly enter the root directory

Since we've already written the makefile, you just need to press the following commands to compile the corresponding files.

```bash
make
```

To play the game, you can either use `elm reactor` or `make host` to start a local server and run the service.

```bash
# Developer Tools
elm reactor

# Directly open the index.html in the browser
make host
```

More detailed game rules can be seen in the game.

---

# Developers

![](/assets/lolipop/lolipopstudios.png)

**Lolipop Studios:** Apeel Subedi, Hongrui Fu, Tiantong Li

> Sweet ideas, crunchy gameplay.

---

# Acknowledgements

- Developed in **Elm**
- Powered by **Gitea**
- Engineered by **Lolipop Studios**

---

# License

<!-- Read https://www.makeareadme.com/ and update this file accordingly. -->
