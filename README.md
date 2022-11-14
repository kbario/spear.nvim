<div align="center">

![logo](logo.svg)

</div>
<div align="center">

# Spear

**Blazingly fast intrafolder neovim file navigation.**

*Reduce the number of keystrokes and the cognitive overhead needed to move to a 
neighbouring file.*

</div>

> todo: add a demo 

## the problem
Multi-file components and units of work (UOW) are great for organising your code
and having separation of concern, but navigating between them can become tedious,
especially if done frequently and over multiple UOW.

You could use file trees, splits, fuzzy finders, or global marks to move between 
files, but these solutions can either be far too powerful, tedious, or both just 
to move to a neighbouring file.

## spear
Spear lets you map the navigation to a specific file extension in the current 
folder to a keybinding.

```bash
spear_bind("<leader>sj", ".ts")
```
Spearing is relative to the folder, so the same keybinding works throughout the
entire project given there are files with that extension in the current folder.

Spear relies on a UOW folder structure where the folder name is the same as it's
files, with extensions appending the folder name. e.g.

```bash
header
 ├─ header.ts
 ├─ header.css
 ├─ header.html
 └─ header.test.ts
 ```
 This is great not only for file extentions like `.tsx`, `.html`, and `.css` but also
 descriptive extensions like `_helper.ts` or `_utils.ts`.

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

## setup

To customise the global default settings of spear, put this somewhere in your config:

```lua
require("spear").setup({
  -- how you want spear to match extensions if multiple are provided
  -- "first" (default): spears to the first extension matched
  -- "next": spears to the next extension matched if the first matches current
  match_pref = "first",
  -- will save the file you are spearing from when you spear from it
  -- false (default)
  -- true
  save_on_spear = false,
  -- whether or not to print error messages
  -- true (default)
  -- false
  print_err = true,
  -- whether or not to print info messages such as 'speared to app.tsx'
  -- true (default)
  -- false
  print_info = true,
})

  -- if you are already in the matched file, you stay there
      -- useful for extensions that don't often exist in the same file,
      -- or for mutually exclusive filetypes (css, scss and sass)
```

## api

`spear( ext: string | table<string>, overrides: table<config> or {})`

Actually spears you to the file in the current folder with the provided extension
if one is found using the config (if any) provided

#### ext 

`spear( extensions: string|table<string>, overrides?: table<config>)` 

extentions: the extension(s) as a string (or table of)

`spear_bind()`
spear you to a file with the provided extension if one is found, the other 
allows you to map the spear to a keybinding

```lua

```

## use case

### angular 

```lua
app
 ├─ app.component.ts        -- spear_bind("<leader>sj", ".component.ts")
 ├─ app.component.html      -- spear_bind("<leader>sj", ".component.html")
 ├─ app.component.css       -- spear_bind("<leader>sj", ".component.css")
 └─ app.component.spec.ts   -- spear_bind("<leader>sj", ".component.spec.ts")
```

 <!-- spear_bind("<leader>sj", "app.component.ts") -->
 <!-- spear_bind("<leader>sk", "app.component.html") -->
 <!-- spear_bind("<leader>sl", "app.component.css") -->
 <!-- spear_bind("<leader>s;", "app.component.spec.ts") -->

### solidjs 

```lua
navbar
 ├─ navbar.tsx        -- spear_bind("<leader>sj", ".tsx")
 ├─ navbar.css        -- spear_bind("<leader>sj", ".css")
 ├─ navbar.test.ts    -- spear_bind("<leader>sj", ".test.ts")
 └─ navbar_helper.ts  -- spear_bind("<leader>sj", "_helper.ts")
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


