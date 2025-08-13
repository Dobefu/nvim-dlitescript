# nvim-dlitescript

A NeoVim plugin that adds syntax highlighting for DLiteScript.

## Features

- **Syntax Highlighting**: Full tree-sitter based highlighting for DLiteScript files
- **File Type Detection**: Automatic detection of `.dl` files as DLiteScript files

## Requirements

- NeoVim 0.8+
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [tree-sitter-dlitescript](../tree-sitter-dlitescipt) parser (auto-installed if configured)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'Dobefu/nvim-dlitescript',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-dlitescript').setup()
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'Dobefu/nvim-dlitescript',
  requires = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('nvim-dlitescript').setup()
  end,
}
```
