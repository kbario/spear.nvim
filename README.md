<div align="center">

![logo](logo.svg)

</div>
<div align="center">

# Spear

**Blazingly fast intrafolder neovim file navigation.**

*Reduce the number of keystrokes and the cognitive overhead needed to move within
folders with consistent file structures.*

</div>

> todo: add a demo 

## the problem
Multi-file components and units of work (UOW) are great for organising your code
and having separation of concern, but navigating between them can become tedious,
especially if done frequently and over multiple UOW.

You could use file trees, splits, fuzzy finders, or global marks to move between 
files, but these solutions can either be way too powerful, tedious, or both just 
to move to a neighbouring file.

## spear
Spear lets you map the navigation to a specific file extension in the current 
folder to a keybinding.

```bash
spear_bind("<leader>sj", ".ts")
```
This navigation is completely relative to the folder you are in, 

Spear relies on projects following a UOW file structure where the folder name is
the same as it's files, only differing by their extension.

```bash
header
 ├─ header.ts
 ├─ header.css
 ├─ header.html
 └─ header.test.ts
 ```

## logic

Spear assumes that the name of the folder you're in is the name of the file and 
everything else in the filename is the extension so you can do more than just filetypes, 
but also add **descriptors**.

```bash
header    //unit of work name
 └─ header.component.spec.ts
      |            |
//  unit of     extension
//  work name
 ```

## use case

Your project folder structure

```bash
main
 ├─ main.ts
 └─ main_helper.ts
```
Spear config

```lua 
-- jump to the main file
vim.keymap.set("n", "<leader>sj", function() spear(".ts") end)

-- jump to the helper
vim.keymap.set("n", "<leader>sk", function() spear("_helper.ts") end)
```
#### Angular
```bash
app
 ├─ app.component.ts
 ├─ app.component.html
 ├─ app.component.css
 └─ app.component.spec.ts
```
Spear config

```lua 
vim.keymap.set("n", "<leader>sj", function() spear(".component.ts") end)
vim.keymap.set("n", "<leader>sk", function() spear(".component.html") end)
vim.keymap.set("n", "<leader>sl", function() spear(".component.css") end)
vim.keymap.set("n", "<leader>s;", function() spear(".component.spec.ts") end)
```

## install

Easily setup with your favourite plugin manager, common ones below.

### [Packer](https://github.com/wbthomason/packer.nvim)
```lua 
use {
  "kbario/spear.nvim",
  requires = {"nvim-lua/plenary.nvim"} -- if you don't have it already
}
```

### [Plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'nvim-lua/plenary.nvim' " if you don't have it already
Plug "kbario/spear.nvim"
```

## api

Right now, spear is the only function

```lua 
spear( extension: string | table{strings}, overides: table{} )
```

Its main argument is the extention you want the file you move to to have, 
and this can either be a string or a table of strings.

Its second argument is optional and is the global options you wish to overide for this spear only.

### multiple inputs

When giving a table of extensions, the default behaviour is the first extension 
to match a file in the current folder will be the one you spear to. This is usesful for:

#### interchangeable filetypes

css, sass, and scss all serve the same purpose, just depends on the project.

```lua
spear({ "component.css", "component.sass", "component.scss" })
```

#### filetypes that will never coexist

```lua
spear({"component.ts", "pipe.ts"})
```

### options

The options and overides are

```lua
overides = {
  
  -- if multiple extentions are given, how do you want them to match?
  -- valid args = first, swap
  -- first (default) uses the first extension that exists in the current folder
    -- does nothing if already in the first extension that matches
  -- swap will use the first extension that matches in the current folder
    -- will swap to the next extension that matches if already in the first extension
  match_pref = "first",

  -- do you want to save the file you spear from when you spear to another file?
  -- takes a boolean
  -- default = false
  save_on_spear = false

}
```
## lsp setup

Add the following to your nvim setup.

Essentially the client attach will run when the lsp name matches one of its values. 
This adds the keymaps conditionally. This was derived from [tj's](https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/lsp/init.lua) 
and [the primeagen's](https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/after/plugin/lsp.lua) config's. Check them out to build on this.

``` lua
-- first require spear
require("spear").setup({
  match_pref: "first",
  save_on_spear: false
})

-- then bind a spear to your preferred keys
-- feel free to make these global or
-- adds these functions for specific lsp clients like below
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

- **foolproof client attach**: currently angularls and typescript files will conflict with each other.
Improving how you set conditions, if angularls attaches, typescript keymaps do not.
- **more customisation**: setup your spear to work for you, the way you want it to.



Spear - a folder navigation plugin - was designed as a couterpart to [harpoon](https://github.com/ThePrimeagen/harpoon) - 
a global file navigation plugin - so that once you're in a folder, going between files is a breeze.


