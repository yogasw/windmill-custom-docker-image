core.register_action("log_response_body", { "http-res" }, function(txn)
    -- Escape response body
    local res_body = txn:get_var("res.body")
    if res_body then
        res_body = res_body:gsub('"', '\\"')
        txn:set_var("res.body", res_body)
    else
        txn:set_var("res.body", "")
    end
end)

-- Fungsi untuk baca body request
core.register_action("read_full_body", { "http-req" }, function(txn)
    local http = txn.http
    if not http then
        core.Alert("read_full_body: txn.http is nil")
        txn:set_var("req.body", "-")
        return
    end

    local body = http:req_get_body()
    if not body then
        body = "-"
    end

    body = body:gsub('"', '\\"')
    txn:set_var("req.body", body)
    core.Info("Request body: " .. body)
end)

