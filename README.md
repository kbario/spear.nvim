<div style="display: flex;">

<div style="display: flex; flex-direction: column; justify-content: center;"> 

# Spear

A lightweight plugin for blazingly fast intrafolder neovim file navigation (or spearing).



</div>

![logo](logo.svg)

 </div>

## the problem

Folders are used to organise code, and often, the files in those folders follow common file structures.
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
 - set some global marks or use a fuzzy finder (to move to the file literally right next to the one you're in).

or you could try:

## the solution: Spear

Spear lets you navigate to commonly used filetypes in the current folder, blazingly fast.

Inspired by [harpoon](https://github.com/ThePrimeagen/harpoon)'s sweetly smooth file movement with the press of a homerow key, 
spear is designed to map your homerows to navigate to specific, commonly used filetypes in the current folder.

## install

Easily setup with your favourite plugin manager, common ones below.

### [Packer](https://github.com/wbthomason/packer.nvim)
```lua 
-- with packer setup
return require('packer').startup(function(use)
  use("wbthomason/packer.nvim")
  use("kbario/spear.nvim")
end

-- to add to existing packer
use("kbario/spear.nvim")
```

### [Plug](https://github.com/junegunn/vim-plug)
```vimscript
call plug#begin()
Plug "kbario/spear.nvim"
call plug#end()
```

## api

The root and only function is `spear( extension: string | sting{} )`. It takes one argument - 
the extention you want the file you move to to have - which can either be a string
or a table of strings.

### logic

Spear assumes that the name of the folder you're in is the name of the file and 
everything else in the filename is the extension.

```bash
header    //unit of work name
 └─ header.component.spec.ts
      |            |
//  unit of     extension
//  work name
 ```

This is so you can do more than just file extensions, but also add descriptors.

e.g. helper functions only for that component can be stored in navbar_helper.ts
and then main component is navbar.ts

spear config for this scenario

```lua 
-- jump to the main file
spear(".ts")

-- jump to the helper
spear("_helper.ts")
```

### multiple inputs

For the table, the first extension to match and be a valid file name, is the one 
you spear to. This is usesful for:

 - interchangeable filetypes
 e.g. {"component.css", "component.sass", "component.scss"}
 - filetypes that will never coexist
 e.g. {"component.ts", "pipe.ts"}

## lsp setup

Add the following to your nvim setup.

Essentially the client attach will run when the lsp name matches one of its values. 
This adds the keymaps conditionally. This was derived from [tj's](https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/lsp/init.lua) 
and [the primeagen's](https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/after/plugin/lsp.lua) config's. Check them out to build on this.

``` lua
-- adds functions when the lsp client attaches
local client_attach = setmetatable({
  angularls = function()
  -- using standard nvim api
    vim.keymap.set("n", "<leader>sj", function()
      spear(".component.ts")
    end)
    vim.keymap.set("n", "<leader>sk", function()
      spear(".component.html")
    end)
    vim.keymap.set("n", "<leader>sl", function()
      spear({".component.css", ".component.scss"})
    end)
    vim.keymap.set("n", "<leader>s;", function()
      spear(".component.spec.ts")
    end)
end
}, {
  __index = function()
    return function() end
  end,
})

local function config(_config, client)
  return vim.tbl_deep_extend("force", {
    capabilities = capabilities -- TODO add capabilities
    on_attach = function(client)
      -- TODO insert your remaps for your lsp here

      -- Attach any client specific options
      client_attach[client]()
    end
  })
end

require("lspconfig").angularls.setup(config({}, "angularls"))
```

## WIP

Spear is still a work in progress, use it with that in mind.

Future features include:

- **same-finger file swap**: assign to extensions to one finger, if you're in the first,
it will switch to the second, and vice versa.
- **foolproof client attach**: currently angularls and typescript files will conflict with each other.
Improving how you set conditions, if angularls attaches, typescript keymaps do not.
- **more customisation**: setup your spear to work for you, the way you want it to.


