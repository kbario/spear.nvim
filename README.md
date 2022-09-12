# Spear

A lightweight plugin for blazingly fast intrafolder file navigation.

## the problem

Folders often contain files concerned with one aspect of a component or unit of work.
A classic example is angular's component folder structure.

```bash
Component
    ├─ component.html
    ├─ component.scss
    ├─ component.ts
    └─ component.spec.ts
```

Each file codes some part of the component which is great for clean code but an absolute giant pain in the ass when you need to constantly switch between files.

You could try: 
 - navigating using a file tree (with the 20 keystrokes it takes per file transfer),
 - setting up multiple splits (just to set them up for the next component 5 mins later),
 - set some global marks (to move to the file literally right next to the one you're in).

or you could try:

## the solution: Spear

Spear lets you navigate to commonly used filetypes in the current folder, blazingly fast.

Inspired by [harpoon](https://github.com/ThePrimeagen/harpoon)'s sweetly smooth file movement with the press of a homerow key
spear is designed to map your homerows to navigate to a specific filetype in the current folder.

---

## setup



