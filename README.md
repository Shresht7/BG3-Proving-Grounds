# `BG3-Proving-Grounds`


Welcome to the Proving-Grounds. This mod project is for ideas and experiments that I want to swiftly prototype, without turning them into an actual mod yet. This repository is an amalgamation of a variety of mod-ideas, where an idea is tested before it evolves into a separate project of its own.

## 🏗️ Repository Structure

Unlike conventional mods, the files here are loosely symlinked to the game's data folder rather than packed into `.pak` files - as the entire point of this project is quick-iteration and prototyping.

### `main`

The `main` branch serves as the foundation, encompassing essential setup elements applicable to any project. All ideas are branched off the `main` branch but are never meant to be merged back in. The `main` branch is meant to serve as a clean-state.

### Branches

Each idea resides in its own branch, (stemming from the `main` branch). This keeps the ideas isolated from one another (and `main`).

When working on a specific idea, switch to the corresponding branch, commit your changes, and stow the branch away. The git history of each branch should succinctly document the evolution of the mod.

If updates are made to the `main` branch, consider **rebasing** the feature branches onto the `main` branch. This action propels the entire branch forward to the latest commit on `main`, seamlessly integrating any changes. `-force` pushing the experimental branches to `origin` is okay! as they are not meant to be merged anyway.

In scenarios where multiple mods are required, create a new branch to merge these mods. Just remember, **never merge back to `main`**.

## 📦 Installation

The mod files are symlinked to the game's data folder instead of being `.pak`ed. See [`Scripts/Symlink-GameDataFolder.ps1`](./Scripts//Symlink-GameDataFolder.ps1) for how the script creates the symbolic links. 

---

## Acknowledgements

- **[Larian Studios]** for creating **[Baldur's Gate 3]**.

## 📄 License

This project is licensed under the [MIT License](./LICENSE).

<!-- LINKS -->

[Baldur's Gate 3]: https://baldursgate3.game
[Larian Studios]: http://larian.com
[BG3MM]: https://github.com/LaughingLeader/BG3ModManager
