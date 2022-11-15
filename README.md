<div align="center">

![logo](logo.svg)

</div>
<div align="center">

# Spear

**Blazingly fast intrafolder neovim file navigation.**

*Reduce the number of keystrokes and cognitive overhead needed to move to a 
neighbouring file.*

</div>

> todo: add a demo 

## the problem
Multi-file components and units of work (UOW) are great for organising your code
and having separation of concern, but navigating between them can become tedious,
especially if done frequently and over multiple UOW.

You could use file trees, splits, fuzzy finders, or global marks to move between 
files, but these solutions can either be far too powerful, tedious, or both just 
to move to a file literally next to the one you're in.

## spear
Spear overcomes this by letting you map the navigation to files with specific 
extensions in your current folder to a keybinding so you can easily move to 
neighbouring files with as few keystrokes as possible.

```bash
spear_bind("<leader>sj", ".ts")
```

Spearing is relative to the folder, so the same keybinding works throughout the
entire project given there are files with that extension in the current folder.

#### just one rule
The file name must be the folder name with the extension appended for Spear's 
matching to work.

```bash
header
 ├─ header.tsx
 ├─ header_utils.ts
 ├─ header.css
 ├─ header.html
 └─ header.test.ts
 ```
This is great not only for file extentions like `.tsx`, `.html`, and `.css` but 
also descriptive extensions like `_helper.ts` or `_utils.ts`.


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

### spear
Actually spears you to the file in the current folder with the provided extension.
```lua
spear( ext: string | table<string>, overrides?: table<config>)
```
|  |  | 
|:---| :--- | 
| Ext: | the extension(s) you want the file you spear to to have. |
| Overrides: *(optional)* | the same as the global settings above, but applied to this spear specifically. |

### spear_bind
Binds the spear to the keybinding provided.
```lua
spear_bind( 
  keybinding: string, 
  ext: string|table<string>, 
  overides: table<config> or {}
)
```

## strategies

If you provide multiple extensions to Spear you can customise the matching
strategy which can become very powerful if use properly. This can be done 
[globally](#setup) or [spear-specific](#api).

### First
Very inuitive; Spear to the first match. This is useful for files that essentially
do the same thing, are interchangeable, or never usually exist in the same file.

This saves from creating multiple spears for extensions that all serve similar 
purposes while still maintaining priority for certain filetypes.

#### interchangeable filetypes

##### CSS
CSS, SASS, and SCSS all serve the same purpose of styling, it just depends on the 
project and you don't want to make 3 or more keybindings or conditionally apply
spears based on the project.

Essentially, the "I just want to go to my styles file" spear.

```lua
spear({ ".css", ".sass", ".scss" })
```
##### js
If your projects mix between typescript and javascript or tsx and jsx then you
could also use

```lua
spear({ ".ts", ".js" }) -- or
spear({ ".tsx", ".jsx" })
```

#### filetypes that will never coexist
##### components, pipes, and services in angular
With angular's opinionated file structure, you often don't see components, pipes
and services in the same file and these file types are the main logic file. 

This is the "I want the main logic file of whatever it is that I'm working on" spear.

```lua
spear({".component.ts", ".pipe.ts", ".service.ts"})
```
### Next
Like First, Next also spears to the first extension it matches but it also checks
and removes the current file from the spear list.

This can be useful if you have to files you want to swap between, but when you're
in neither you go to the first extension.

##### main and helpers
a good use case for this may be spearing between your main `.ts` file for a UOW and
the `_helper.ts` file. 

```lua
spear({ ".ts", "_helper.ts" })
```
A caveat is that the helper is always behind the main file but if you often only
work on the helper while in main may be a trade-off you will take.

## examples

### angular 
Working with Angular was the initial inspiration for Spear so there are few 
efficiencies that can be made if you use spear with Angular.

```lua
-- typical angular file structure
app
 ├─ app.component.ts        
 ├─ app.component.html     
 ├─ app.component.css     
 └─ app.component.spec.ts

-- spear setup
spear_bind("<leader>sj", { ".component.ts", ".service.ts", ".pipe.ts" }, { match_pref = "next"})
spear_bind("<leader>sk", ".component.html")
spear_bind("<leader>sl", { ".component.css", ".component.scss", ".component.sass" })
spear_bind("<leader>s;", { ".component.spec.ts", ".service.spec.ts", ".pipe.spec.ts"}, {match_pref = "next"})
```
By putting all the main logic files on one key, you can easily access them when
you're in component, pipe, or service folder but by adding `match_pref = "next"`
you're also allowing easy access if there happens to be a pipe file in your component
or service file. Just know, if a component and service file exist, you will never
reach the pipe file.

### solidjs 

```lua
navbar
 ├─ navbar.tsx        -- spear_bind("<leader>sj", {".tsx", "_helper.ts"}, {match_pref="next"})
 ├─ navbar.css        -- spear_bind("<leader>sk", ".css")
 ├─ navbar.test.ts    -- spear_bind("<leader>sl", ".test.ts")
 └─ navbar_helper.ts  -- spear_bind("<leader>s;", "_helper.ts")
```
By adding the next `match_pref` you can same-finger swap between `navbar.ts` and 
`navbar_helper.ts` but adding the `navbar_helper.ts` spear on `<leader>s;` also
gives you unblocked access if you're in the `.css` or `.test.ts` files.

## lsp setup

If you want to do some lsp-specific spearing - say when the angular lsp attaches
you add your angular specific spears - then you can do something like below with
a metatable (shoutout to [tjdevries](https://github.com/tjdevries/config_manager/blob/master/xdg_config/nvim/lua/tj/lsp/init.lua) 
for this inspo). 

``` lua
-- if you wish, require and setup spear if you want to override the defaults 
require("spear").setup({
  print_info: false
})

-- then bind a spear to your preferred keys
-- feel free to make these global or
-- adds these functions for specific lsp clients like below
local client_attach = setmetatable({
  angularls = function()
    -- using spear_bind
    -- automatically generates and adds the desc attribute
    spear_bind("<leader>sj", { ".component.ts", ".service.ts" }, { match_pref = "next" })
    spear_bind("<leader>sk", ".component.html")
    spear_bind("<leader>sl", { ".component.css", ".component.scss", ".component.sass" })
    -- or using standard nvim api
    vim.keymap.set("n", "<leader>s;", function()
      spear({ ".component.spec.ts", ".service.spec.ts" }, { match_pref = "next" })
    end, { desc = "spearing/swapping to the component and service.spec.ts file" }),
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

Future development will go towards:

- **foolproof client attach**: currently angularls and typescript files will conflict with each other.
Improving how you set conditions, if angularls attaches, typescript keymaps do not.
- **more customisation**: setup your spear to work for you, the way you want it to.

## contributing

If you see something you don't like, have suggestions or want to extend spear in
any way, please feel free to fork this repo, make a PR and contribute. All are 
welcome, and for guidelines, see [our code of conduct here](./CODE_OF_CONDUCT.md).

## license

Spear is under [MIT license](./LICENSE.md), do with it what you wish but it would mean a lot to
all contributors for a small shoutout when you become famous.

---

Spear - a folder navigation plugin - was designed as a couterpart to [harpoon](https://github.com/ThePrimeagen/harpoon) - 
a global file navigation plugin - so that once you're in a folder, going between files is a breeze.


