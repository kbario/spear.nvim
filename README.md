<div align="center">

![logo](logo.svg)

</div>
<div align="center">

# Spear

Blazingly fast intrafolder neovim file navigation.

</div>

## the problem

Folders are used to organise units of work, and separation of concern breaks this work up into mutlilple files.
A classic example of this is angular's component folder structure.

```bash
src
└─ top-nav     
    ├─ top-nav.component.html
    ├─ top-nav.component.scss
    ├─ top-nav.component.ts
    └─ top-nav.component.spec.ts
```

This is great for organised code but tedious during development, constantly switching between files just to work on one thing.

To overcome this, you could try: 
 - navigating using a file tree (:E down down down down down enter *dammit*... :E down down..)
 - setting up multiple splits (just to set them up for the next component 5 mins later),
 - use global marks or a fuzzy finder (to move to the file literally right next to the one you're in).

or you could use:

## the solution: Spear

Spear lets you navigate to files within the current folder that have specific extension, blazingly fast. 

Spear - a folder navigation plugin - was designed as a couterpart to [harpoon](https://github.com/ThePrimeagen/harpoon) - a global file navigation plugin - so that once you're in the folder you want, going between files is a breeze.

Spear's navigation is relative, so the same keybindings navigate any folder in your project that have files with the designated filetypes.

Ultimately, Spear reduces the number of keystrokes and the cognitive overhead needed to move within a folder.

## logic

Spear assumes that the name of the folder you're in is the name of the file and 
everything else in the filename is the extension.

```bash
header    //unit of work name
 └─ header.component.spec.ts
      |            |
//  unit of     extension
//  work name
 ```

This is so you can do more than just filetypes, but also add descriptors.

An example is you have helper functions only for that component. They can be 
stored in header_helper.ts and then main component is header.ts.

The spear config for this scenario is:

```lua 
-- jump to the main file
spear(".component.ts")

-- jump to the helper
spear("_helper.ts")
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

css, sass, and scss all serve the same purpose, just depends on the project
```lua
spear({ "component.css", "component.sass", "component.scss" })
```

#### filetypes that will never coexist
e.g. {"component.ts", "pipe.ts"}


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


