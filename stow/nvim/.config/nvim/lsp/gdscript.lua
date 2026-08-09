-- Godot's language server is hosted by the running Editor, not by a binary
-- Neovim can spawn, so `cmd` only opens a socket. Without a probe, every .gd
-- buffer opened while the Editor is closed reports
--   Could not connect to 127.0.0.1:6005, reason: "ECONNREFUSED"
local HOST, PORT = "127.0.0.1", 6005

-- `root_markers` is ignored once `root_dir` is a function (:h lsp-root_markers),
-- so the project marker is resolved here instead.
return {
  cmd = vim.lsp.rpc.connect(HOST, PORT),
  filetypes = { "gdscript" },
  -- Reaching on_dir is what activates the client; returning without calling it
  -- skips this buffer silently (:h lsp-root_dir()).
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, "project.godot")
    if not root then
      return
    end

    local tcp = vim.uv.new_tcp()
    if not tcp then
      return
    end

    local settled = false
    local function finish(reachable)
      if settled then
        return
      end
      settled = true
      tcp:close()
      if reachable then
        -- on_dir re-enters the main loop itself, so calling it from this
        -- libuv callback is safe.
        on_dir(root)
      end
    end

    tcp:connect(HOST, PORT, function(err)
      finish(err == nil)
    end)

    -- A dropped SYN never invokes the connect callback; don't leak the handle.
    vim.defer_fn(function()
      finish(false)
    end, 200)
  end,
}
