-- Debugging: codelldb for C, netcoredbg for standalone .NET, and vstuc for
-- attaching to a running Unity Editor.
--
-- codelldb/netcoredbg come from Mason (see lua/plugins/mason.lua). vstuc is
-- Microsoft's Visual Studio Tools for Unity debug adapter, extracted from the
-- marketplace .vsix to VSTUC_DIR below. To update it, re-download from
--   https://marketplace.visualstudio.com/_apis/public/gallery/publishers/
--     visualstudiotoolsforunity/vsextensions/vstuc/latest/vspackage
-- and unzip over that directory.
local VSTUC_DIR = vim.fn.expand("~/.local/share/vstuc")
local VSTUC_DLL = VSTUC_DIR .. "/content/extension/bin/UnityDebugAdapter.dll"

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(cond)
            if cond and cond ~= "" then
              require("dap").set_breakpoint(cond)
            end
          end)
        end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      {
        "<leader>de",
        function() require("dapui").eval(nil, { enter = true }) end,
        desc = "Evaluate expression",
        mode = { "n", "v" },
      },
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step out" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()
      require("nvim-dap-virtual-text").setup({})

      -- Open/close the UI automatically around a session.
      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui"] = function()
        dapui.close()
      end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo" })

      -- C / C++ via codelldb.
      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.exepath("codelldb"),
          args = { "--port", "${port}" },
        },
      }
      dap.configurations.c = {
        {
          name = "Launch executable",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
      }
      dap.configurations.cpp = dap.configurations.c

      -- Standalone .NET via netcoredbg. Unity attach is added separately by
      -- nvim-dap-unity, which appends to this same list.
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.exepath("netcoredbg"),
        args = { "--interpreter=vscode" },
      }
      dap.configurations.cs = {
        {
          name = "Launch .NET assembly",
          type = "coreclr",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
        },
      }

      -- GDScript via the Editor's own DAP server. Enable it under
      -- Editor Settings > Network > Debug Adapter; as with the LSP on 6005
      -- (see lsp/gdscript.lua), the Editor must be running with the project
      -- open before starting a session.
      dap.adapters.godot = {
        type = "server",
        host = "127.0.0.1",
        port = 6006,
      }
      dap.configurations.gdscript = {
        {
          name = "Launch project",
          type = "godot",
          request = "launch",
          project = "${workspaceFolder}",
        },
        {
          name = "Launch current scene",
          type = "godot",
          request = "launch",
          project = "${workspaceFolder}",
          scene = "current",
        },
      }

      -- Unity Editor via Microsoft's vstuc adapter.
      dap.adapters.unity = {
        type = "executable",
        command = "dotnet",
        args = { VSTUC_DLL },
        name = "Attach to Unity",
      }

      -- Unity's process name varies by install method: "Unity"/"Unity.bin" via
      -- the Hub, but "unityhub-unity-<version>" via unity-cli, which the kernel
      -- truncates to "unityhub-unity-". Match case-insensitively to cover both.
      table.insert(dap.configurations.cs, {
        name = "Attach to Unity",
        type = "unity",
        request = "attach",
        endPoint = function()
          if vim.fn.filereadable(VSTUC_DLL) == 0 then
            error("vstuc adapter missing at " .. VSTUC_DLL .. " (see comment at top of dap.lua)", 0)
          end
          local res = vim.system({ "ss", "-tlnp" }, { text = true }):wait()
          if res.code ~= 0 then
            error("nvim-dap-unity: `ss` failed; is iproute2 installed?", 0)
          end
          for line in vim.gsplit(res.stdout, "\n") do
            if line:lower():match("unity") then
              local host, port = line:match("(%d+%.%d+%.%d+%.%d+):(%d+)")
              local n = tonumber(port)
              -- Unity's soft debugger listens in this range.
              if n and n >= 56000 and n <= 57999 then
                return (host or "127.0.0.1") .. ":" .. port
              end
            end
          end
          error("No Unity debugger port found. Is the Editor running with this project open?", 0)
        end,
      })
    end,
  },
}
